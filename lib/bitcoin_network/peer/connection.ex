defmodule BitcoinNetwork.Peer.Connection do
  @max_retries Application.get_env(:bitcoin_network, :max_retries)

  alias BitcoinNetwork.IP
  alias BitcoinNetwork.Peer
  alias BitcoinNetwork.Peer.Packet
  alias BitcoinNetwork.Protocol.{Ping, Version}

  use Connection

  def start_link({ip, port}) do
    Connection.start_link(__MODULE__, %{
      ip: ip,
      port: port,
      rest: "",
      retries: 0
    })
  end

  def init(state) do
    {:connect, nil, state}
  end

  def connect(_info, state = %{retries: @max_retries}) do
    {:stop, :normal, state}
  end

  def connect(_info, state) do
    options = [:binary, active: true]

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

    with {:ok, socket} <-
           :gen_tcp.connect(
             IP.to_tuple(state.ip),
             state.port,
             options,
             Application.get_env(:bitcoin_network, :timeout)
           ),
         :ok <- Peer.send(version, socket) do
      {:ok, Map.put_new(state, :socket, socket)}
    else
      _ -> {:backoff, 1000, Map.put(state, :retries, state.retries + 1)}
    end
  end

  def disconnect(_reason, state = %{socket: socket}) do
    :ok = :gen_tcp.close(socket)
    {:stop, :normal, state}
  end

  def disconnect(_reason, state) do
    {:stop, :normal, state}
  end

  def handle_info({:tcp, _port, data}, state) do
    state = refresh_timeout(state)
    {messages, rest} = Packet.chunk(state.rest <> data)

    IO.inspect(messages)

    case Packet.handle_packets(messages, state) do
      {:ok, state} ->
        {:noreply, %{state | rest: rest}}

      {:error, reason, state} ->
        {:disconnect, reason, %{state | rest: rest}}
    end
  end

  def handle_info({:tcp_closed, _port}, state) do
    {:disconnect, :tcp_closed, state}
  end

  def handle_info(:timeout, state) do
    {:disconnect, :timeout, state}
  end

  def handle_info(:send_ping, state) do
    with :ok <-
           Peer.send(%Ping{nonce: :crypto.strong_rand_bytes(8)}, state.socket) do
      {:noreply, state}
    else
      {:error, reason} -> {:error, reason, state}
    end
  end

  defp refresh_timeout(state = %{timer: timer}) do
    Process.cancel_timer(timer)

    timer =
      Process.send_after(
        self(),
        :timeout,
        Application.get_env(:bitcoin_network, :timeout)
      )

    Map.put(state, :timer, timer)
  end

  defp refresh_timeout(state) do
    timer =
      Process.send_after(
        self(),
        :timeout,
        Application.get_env(:bitcoin_network, :timeout)
      )

    Map.put_new(state, :timer, timer)
  end
end
