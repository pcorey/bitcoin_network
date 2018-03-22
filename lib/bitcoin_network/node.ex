# http://andrealeopardi.com/posts/handling-tcp-connections-in-elixir/

defmodule BitcoinNetwork.Node do
  use GenServer

  alias BitcoinNetwork.Protocol.{Addr, Message, Version}

  def start_link({ip, port}) do
    GenServer.start_link(
      __MODULE__,
      %{ip: ip, port: port},
      name: {:via, Registry, {BitcoinNetwork.NodeRegistry, {ip, port}}}
    )
  end

  def init(state = %{ip: ip, port: port}) do
    [:bright, :white, "Connecting to #{ip_binary_to_string(ip)}:#{port}."]
    |> IO.ANSI.format()
    |> log()

    {:ok, socket} = :gen_tcp.connect(ip_binary_to_tuple(ip), port, [:binary, active: true], 5000)

    :ok =
      Message.serialize("version", %Version{
        version: 31900,
        services: 1,
        timestamp: :os.system_time(:seconds),
        recv_ip: ip,
        recv_port: port,
        from_ip: <<>>,
        from_port: 0,
        nonce: :binary.decode_unsigned(:crypto.strong_rand_bytes(8)),
        user_agent: "Pete rules",
        start_height: 1
      })
      |> send_message(socket)

    {:ok,
     state
     |> Map.put_new(:socket, socket)
     |> Map.put_new(:rest, "")}
  end

  defp ip_binary_to_string(binary) do
    binary
    |> :binary.bin_to_list()
    |> Enum.chunk_every(4)
    |> Enum.map(&:binary.list_to_bin/1)
    |> Enum.map(&Base.encode16/1)
    |> Enum.join(":")
  end

  defp ip_binary_to_tuple(binary) do
    binary
    |> :binary.bin_to_list()
    |> Enum.chunk_every(2)
    |> Enum.map(&:binary.list_to_bin/1)
    |> Enum.map(&:binary.decode_unsigned/1)
    |> List.to_tuple()
  end

  def handle_cast(%Message{command: "version"}, state) do
    :ok =
      Message.serialize("verack")
      |> send_message(state.socket)

    :ok =
      Message.serialize("getaddr")
      |> send_message(state.socket)

    {:noreply, state}
  end

  def handle_cast(%Message{command: "verack"}, state) do
    [:bright, :white, "Got ", :green, "verack", :white, "."]
    |> IO.ANSI.format()
    |> log()

    {:noreply, state}
  end

  def handle_cast(%Message{command: "addr", payload: payload}, state) do
    {:ok, addr} = Addr.parse(payload)

    [:bright, :white, "Received ", :green, "#{length(addr.addr_list)}", :white, " peers."]
    |> IO.ANSI.format()
    |> log()

    addr.addr_list
    |> Enum.sort_by(& &1.time, &>=/2)
    |> Enum.map(fn %{ip: ip, port: port} ->
      Task.start(fn -> BitcoinNetwork.connect(ip, port) end)
    end)

    {:noreply, state}
  end

  def handle_cast(%Message{command: "ping"}, state) do
    [:bright, :white, "Got ", :green, "ping", :white, ", sending ", :yellow, "pong", :white, "."]
    |> IO.ANSI.format()
    |> log()

    :ok =
      Message.serialize("pong")
      |> send_message(state.socket)

    {:noreply, state}
  end

  def handle_cast(%Message{}, state) do
    {:noreply, state}
  end

  def chunk(binary, messages \\ []) do
    case Message.parse(binary) do
      {:ok, message, rest} ->
        chunk(rest, messages ++ [message])

      nil ->
        {messages, binary}
    end
  end

  def handle_info({:tcp_closed, _port}, state) do
    {:noreply, state}
  end

  def handle_info({:tcp, _port, data}, state = %{rest: rest}) do
    {messages, rest} = chunk(rest <> data)

    messages
    |> Enum.filter(&Message.verify_checksum/1)
    |> Enum.map(&GenServer.cast(self(), &1))

    {:noreply, %{state | rest: rest}}
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

  def log(message) do
    [:bright, :black, "[#{inspect(self())}] ", :reset, message]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  def send_message(message, socket), do: :gen_tcp.send(socket, message)
end
