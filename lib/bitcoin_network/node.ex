# http://andrealeopardi.com/posts/handling-tcp-connections-in-elixir/

defmodule BitcoinNetwork.Node do
  use GenServer

  alias BitcoinNetwork.Protocol.{Addr, Message, Ping, Version}

  def start_link({ip, port}) do
    GenServer.start_link(__MODULE__, %{ip: ip, port: port})
  end

  def init(state = %{ip: ip, port: port}) do
    {:ok, socket} =
      :gen_tcp.connect(BitcoinNetwork.IP.to_tuple(ip), port, [:binary, active: true])

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
      |> send_message(socket)

    {:ok,
     state
     |> Map.put_new(:socket, socket)
     |> Map.put_new(:rest, "")}
  end

  def handle_info({:tcp, _port, data}, state = %{rest: rest}) do
    {messages, rest} = chunk(rest <> data)

    messages
    |> Enum.filter(&Message.verify_checksum/1)
    |> Enum.map(& &1.parsed_payload)
    |> Enum.map(&handle_payload/1)
    |> List.flatten()
    |> Enum.reduce(:ok, fn message, :ok ->
      send_message(message, state.socket)
    end)

    {:noreply, %{state | rest: rest}}
  end

  def handle_info({:tcp_closed, _port}, state) do
    {:noreply, state}
  end

  defp handle_payload(%Version{}) do
    [
      Message.serialize("verack"),
      Message.serialize("getaddr")
    ]
  end

  defp handle_payload(%Ping{}) do
    [
      Message.serialize("pong")
    ]
  end

  defp handle_payload(%Addr{addr_list: addr_list}) do
    IO.puts("hi")

    [:bright, "Received ", :green, "#{length(addr_list)}", :reset, :bright, " peers."]
    |> log()

    []
  end

  defp handle_payload(_) do
    []
  end

  defp chunk(binary, messages \\ []) do
    case Message.parse(binary) do
      {:ok, message, rest} ->
        chunk(rest, messages ++ [message])

      nil ->
        {messages, binary}
    end
  end

  defp log(message) do
    [:bright, :black, "[#{inspect(self())}] ", :reset, message]
    |> IO.ANSI.format()
    |> IO.puts()
  end

  defp send_message(message, socket) do
    message
    |> Hexdump.to_string()
    |> IO.puts()

    :gen_tcp.send(socket, message)
  end
end
