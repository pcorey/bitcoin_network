# http://andrealeopardi.com/posts/handling-tcp-connections-in-elixir/

defmodule BitcoinNetwork.Node do
  use GenServer

  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.{Message, Version}

  def start_link({ip, port}) do
    GenServer.start_link(
      __MODULE__,
      %{ip: ip, port: port},
      name: {:via, Registry, {BitcoinNetwork.NodeRegistry, {ip, port}}}
    )
  end

  def init(state = %{ip: ip, port: port}) do
    {:ok, socket} = :gen_tcp.connect(String.to_charlist(ip), port, [:binary, active: true])

    :ok =
      Message.serialize("version", %Version{
        version: 31900,
        services: 1,
        timestamp: :os.system_time(:seconds),
        recv_ip: string_to_bytes(ip),
        recv_port: port,
        from_ip: string_to_bytes("66.18.56.40"),
        from_port: 8333,
        nonce: :binary.decode_unsigned(:crypto.strong_rand_bytes(8)),
        user_agent: "",
        start_height: 1
      })
      |> print_message(state, [:yellow])
      |> send_message(socket)

    {:ok, Map.put_new(state, :socket, socket)}
  end

  defp string_to_bytes(ip) do
    ip
    |> String.split(".")
    |> Enum.map(&String.to_integer/1)
    |> :binary.list_to_bin()
  end

  def handle_cast({:message, data = <<_magic::32, "version", _::binary>>}, state) do
    print_message(data, state, [:green])

    {:ok, message} = Message.parse(data)

    version =
      message
      |> Map.get(:payload)
      |> BitcoinNetwork.Protocol.Version.parse()

    :ok =
      Message.serialize("verack")
      |> print_message(state, [:yellow])
      |> send_message(state.socket)

    :ok =
      Message.serialize("getaddr")
      |> print_message(state, [:yellow])
      |> send_message(state.socket)

    {:noreply, state}
  end

  def handle_cast({:message, data = <<_magic::32, "verack", _::binary>>}, state) do
    print_message(data, state, [:green])
    {:noreply, state}
  end

  def handle_cast({:message, data = <<_magic::32, "ping", _::binary>>}, state) do
    print_message(data, state, [:green])

    :ok =
      Message.serialize("pong")
      |> print_message(state, [:yellow])
      |> send_message(state.socket)

    {:noreply, state}
  end

  def handle_cast({:message, data = <<_magic::32, "addr", _::binary>>}, state) do
    print_message(data, state, [:green])

    {:noreply, state}
  end

  def handle_cast({:message, data}, state) do
    print_message(data, state, [:bright, :black])
    {:noreply, state}
  end

  def handle_info({:tcp, _port, data}, state) do
    data
    |> String.split(Application.get_env(:bitcoin_network, :magic), trim: true)
    |> Enum.map(&(Application.get_env(:bitcoin_network, :magic) <> &1))
    |> Enum.map(&GenServer.cast(self(), {:message, &1}))

    {:noreply, state}
  end

  def print_message(data, %{ip: ip, port: port}, colors) do
    output =
      data
      |> Hexdump.to_string()

    (colors ++ ("#{ip}:#{port} @ #{DateTime.utc_now()}\n" <> output <> "\n"))
    |> IO.ANSI.format()
    |> IO.puts()

    data
  end

  def send_message(message, socket), do: :gen_tcp.send(socket, message)
end
