# http://andrealeopardi.com/posts/handling-tcp-connections-in-elixir/

defmodule BitcoinNetwork.Node do
  use Connection

  alias BitcoinNetwork.IP
  alias BitcoinNetwork.Protocol.{Addr, Message, Ping, Version}

  def start_link({ip, port}) do
    Connection.start_link(__MODULE__, %{ip: ip, port: port, rest: ""})
  end

  def init(state) do
    {:connect, nil, state}
  end

  def connect(_, state) do
    options = [:binary, active: true]

    version = %Version{
      version: 31900,
      services: 1,
      timestamp: :os.system_time(:seconds),
      recv_ip: state.ip,
      recv_port: state.port,
      from_ip: <<>>,
      from_port: 0,
      nonce: :binary.decode_unsigned(:crypto.strong_rand_bytes(8)),
      user_agent: "Elixir rules!",
      start_height: 1
    }

    message = Message.serialize("version", version)

    with {:ok, socket} <- :gen_tcp.connect(IP.to_tuple(state.ip), state.port, options),
         :ok <- send_message(message, socket) do
      {:ok, Map.put_new(state, :socket, socket)}
    else
      _ -> {:backoff, 1000, state}
    end
  end

  def disconnect(_, state) do
    :ok = :gen_tcp.close(state.socket)
    {:stop, :disconnect, state}
  end

  def handle_info({:tcp, _port, data}, state) do
    {messages, rest} = chunk(state.rest <> data)

    case handle_messages(messages, state) do
      {:disconnect, state} -> {:disconnect, %{state | rest: rest}}
      state -> {:noreply, %{state | rest: rest}}
    end
  end

  def handle_info({:tcp_closed, _port}, state) do
    {:noreply, state}
  end

  defp handle_messages(messages, state) do
    messages
    |> Enum.filter(&Message.verify_checksum/1)
    |> Enum.reduce_while(state, fn message, state ->
      case handle_payload(message.parsed_payload, state) do
        {:error, reason, state} -> {:halt, {:disconnect, reason, state}}
        {:ok, state} -> {:cont, state}
      end
    end)
  end

  defp handle_payload(%Version{}, state) do
    with :ok <- Message.serialize("verack") |> send_message(state.socket),
         :ok <- Message.serialize("getaddr") |> send_message(state.socket) do
      {:ok, state}
    else
      {:error, reason} -> {:error, reason, state}
    end
  end

  defp handle_payload(%Ping{}, state) do
    with :ok <- Message.serialize("pong") |> send_message(state.socket) do
      {:ok, state}
    else
      {:error, reason} -> {:error, reason, state}
    end
  end

  defp handle_payload(%Addr{addr_list: addr_list}, state) do
    [:bright, "Received ", :green, "#{length(addr_list)}", :reset, :bright, " peers."]
    |> log()

    {:ok, state}
  end

  defp handle_payload(_payload, state), do: {:ok, state}

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
    :gen_tcp.send(socket, message)
  end
end
