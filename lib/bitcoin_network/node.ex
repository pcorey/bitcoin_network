# http://andrealeopardi.com/posts/handling-tcp-connections-in-elixir/

defmodule BitcoinNetwork.Node do
  use GenServer

  alias BitcoinNetwork.Protocol.{Addr, Message, Version}

  def start_link({ip, port}) do
    GenServer.start_link(__MODULE__, %{ip: ip, port: port})
  end

  def init(state = %{ip: ip, port: port}) do
    [:bright, "Connecting to #{ip_binary_to_string(ip)}:#{port}."]
    |> log()

    {:ok, socket} = :gen_tcp.connect(ip_binary_to_tuple(ip), port, [:binary, active: true])

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
        user_agent: "Elixir rules!",
        start_height: 1
      })
      |> print_message([:bright, :yellow])
      |> send_message(socket)

    {:ok,
     state
     |> Map.put_new(:socket, socket)
     |> Map.put_new(:rest, "")}
  end

  def handle_cast(%Message{command: "version"}, state) do
    :ok =
      Message.serialize("verack")
      |> print_message([:bright, :yellow])
      |> send_message(state.socket)

    :ok =
      Message.serialize("getaddr")
      |> print_message([:bright, :yellow])
      |> send_message(state.socket)

    {:noreply, state}
  end

  def handle_cast(%Message{command: "verack"}, state) do
    [:bright, "Got ", :green, "verack", :reset, :bright, "."]
    |> log()

    {:noreply, state}
  end

  def handle_cast(%Message{command: "addr", payload: payload}, state) do
    {:ok, addr} = Addr.parse(payload)

    [:bright, "Received ", :green, "#{length(addr.addr_list)}", :reset, :bright, " peers."]
    |> log()

    {:noreply, state}
  end

  def handle_cast(%Message{command: "ping"}, state) do
    [
      :bright,
      "Got ",
      :green,
      "ping",
      :reset,
      :bright,
      ", sending ",
      :yellow,
      "pong",
      :reset,
      :bright,
      "."
    ]
    |> log()

    :ok =
      Message.serialize("pong")
      |> print_message([:bright, :yellow])
      |> send_message(state.socket)

    {:noreply, state}
  end

  def handle_cast(%Message{}, state) do
    {:noreply, state}
  end

  def handle_info({:tcp, _port, data}, state = %{rest: rest}) do
    {messages, rest} = chunk(rest <> data)

    messages
    |> Enum.filter(&Message.verify_checksum/1)
    |> Enum.map(&GenServer.cast(self(), &1))

    {:noreply, %{state | rest: rest}}
  end

  def handle_info({:tcp_closed, _port}, state) do
    {:noreply, state}
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

  defp chunk(binary, messages \\ []) do
    case Message.parse(binary) do
      {:ok, message, rest} ->
        chunk(rest, messages ++ [message])

      nil ->
        {messages, binary}
    end
  end

  defp print_message(data, colors) do
    output =
      data
      |> Hexdump.to_string()

    (colors ++ ("\n" <> output <> "\n"))
    |> IO.ANSI.format()
    |> IO.puts()

    data
  end

  defp log(message) do
    [:bright, :black, "[#{inspect(self())}] ", :reset, message]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  defp send_message(message, socket), do: :gen_tcp.send(socket, message)
end
