defmodule BitcoinNetwork.Peer.Packet do
  alias BitcoinNetwork.Peer.Payload
  alias BitcoinNetwork.Protocol.Message

  def handle_packets(messages, state) do
    messages
    |> Enum.filter(&Message.Checksum.verify_checksum/1)
    |> Enum.reduce_while(state, fn message, state ->
      case Payload.handle_payload(message.payload, state) do
        {:error, reason, state} -> {:halt, {:error, reason, state}}
        {:ok, state} -> {:cont, state}
      end
    end)
  end

  def chunk(binary, messages \\ []) do
    case Message.parse(binary) do
      {:ok, message, rest} ->
        chunk(rest, messages ++ [message])

      {:error, _reason} ->
        {messages, binary}
    end
  end
end
