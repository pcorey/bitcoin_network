defmodule BitcoinNetwork.Peer.Connection do
  @max_retries Application.get_env(:bitcoin_network, :max_retries)

  alias BitcoinNetwork.IP
  alias BitcoinNetwork.Peer
  alias BitcoinNetwork.Peer.Workflow
  alias BitcoinNetwork.Protocol.{Message, Version}

  import BitcoinNetwork.Protocol.Value, only: [value: 1]

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

    version =
      Version.new(
        state.ip,
        state.port,
        Application.get_env(:bitcoin_network, :services),
        Application.get_env(:bitcoin_network, :user_agent)
      )

    with {:ok, socket} <- :gen_tcp.connect(ip, state.port, options, timeout),
         :ok <- Peer.send(version, socket) do
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
    with {:ok, part_one} <- recv(state, 24),
         {:ok, message, _rest} <- Message.parse(part_one),
         {:ok, part_two} <- recv(state, value(message.size)),
         {:ok, module} <- Message.parse_payload_module(message.command),
         {:ok, payload, <<>>} <- apply(module, :parse, [part_two]),
         {:ok, _checksum} <- Message.verify_checksum(message, payload),
         {:ok, state} <- Workflow.handle_payload(payload, state) do
      [
        :reset,
        :bright,
        :green,
        (part_one <> part_two)
        |> Hexdump.to_string()
      ]
      |> IO.ANSI.format()
      |> IO.chardata_to_string()
      |> IO.puts()

      GenServer.cast(self(), :recv)
      {:noreply, state}
    else
      {:error, :unsupported_command} ->
        GenServer.cast(self(), :recv)
        {:noreply, state}

      {:error, reason} ->
        {:disconnect, reason, state}
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
end
