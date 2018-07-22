defmodule BitcoinNetwork.Peer.Connection do
  @max_retries Application.get_env(:bitcoin_network, :max_retries)

  alias BitcoinNetwork.IP
  alias BitcoinNetwork.Peer
  alias BitcoinNetwork.Peer.Workflow
  alias BitcoinNetwork.Protocol.{Message, Ping, Version}

  require Logger

  use Connection

  def start_link({ip, port}) do
    Connection.start_link(__MODULE__, %{
      ip: ip,
      port: port,
      retries: 0,
      timer: nil
    })
  end

  def init(state) do
    {:connect, nil, state}
  end

  def connect(_info, state = %{retries: @max_retries}) do
    {:stop, :normal, state}
  end

  def connect(_info, state) do
    options = [:binary, active: false]
    ip = IP.to_tuple(state.ip)
    timeout = Application.get_env(:bitcoin_network, :timeout)

    version = %Version{
      version: Application.get_env(:bitcoin_network, :version),
      services: Application.get_env(:bitcoin_network, :services),
      user_agent: Application.get_env(:bitcoin_network, :user_agent),
      from_ip: <<>>,
      from_port: 0,
      from_services: Application.get_env(:bitcoin_network, :services),
      timestamp: :os.system_time(:seconds),
      recv_ip: state.ip,
      recv_port: state.port,
      recv_services: Application.get_env(:bitcoin_network, :services),
      nonce: :binary.decode_unsigned(:crypto.strong_rand_bytes(8)),
      start_height: 1
    }

    with {:ok, socket} <- :gen_tcp.connect(ip, state.port, options, timeout),
         {:ok, _serialized} <- Peer.send(version, socket) do
      GenServer.cast(self(), :recv)
      {:ok, Map.put_new(state, :socket, socket)}
    else
      _ -> {:backoff, 1000, Map.put(state, :retries, state.retries + 1)}
    end
  end

  def disconnect(reason, state = %{socket: socket}) do
    :ok = :gen_tcp.close(socket)
    disconnect(reason, Map.delete(state, :socket))
  end

  def disconnect(reason, state) do
    Logger.info(
      [
        :reset,
        :bright,
        :red,
        "#{inspect(reason)}",
        :reset
      ]
      |> IO.ANSI.format()
      |> IO.chardata_to_string()
    )

    {:stop, :normal, state}
  end

  def handle_cast(:recv, state) do
    with {:ok, message} <- recv(state, 24),
         {:ok, message, _rest} <- Message.parse(message),
         {:ok, payload} <- recv(state, message.size),
         {:ok, module} <- Message.parse_payload_module(message.command),
         {:ok, payload, _rest} <- apply(module, :parse, [payload]),
         {:ok, _checksum} <- Message.verify_checksum(message, payload),
         {:ok, state} <- Workflow.handle_payload(payload, state) do
      GenServer.cast(self(), :recv)
      {:noreply, refresh_timeout(state)}
    else
      {:error, :unsupported_command} ->
        GenServer.cast(self(), :recv)
        {:noreply, refresh_timeout(state)}

      {:error, reason} ->
        {:disconnect, reason, refresh_timeout(state)}
    end
  end

  def handle_info(:timeout, state) do
    {:disconnect, :timeout, state}
  end

  def handle_info(:ping, state) do
    with nonce <- :crypto.strong_rand_bytes(8),
         {:ok, _serialized} <- Peer.send(%Ping{nonce: nonce}, state.socket) do
      {:noreply, state}
    else
      {:error, reason} -> {:disconnect, reason, state}
    end
  end

  defp recv(_state, 0),
    do: {:ok, <<>>}

  defp recv(%{socket: socket}, length),
    do:
      :gen_tcp.recv(
        socket,
        length,
        Application.get_env(:bitcoin_network, :timeout)
      )

  defp refresh_timeout(state = %{timer: nil}) do
    Map.put(
      state,
      :timer,
      Process.send_after(
        self(),
        :timeout,
        Application.get_env(:bitcoin_network, :timeout)
      )
    )
  end

  defp refresh_timeout(state = %{timer: timer}) do
    Process.cancel_timer(timer)
    refresh_timeout(Map.put(state, :timer, nil))
  end
end
