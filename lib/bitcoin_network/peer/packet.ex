defmodule BitcoinNetwork.Peer.Packet do
  alias BitcoinNetwork.Peer.Workflow
  alias BitcoinNetwork.Protocol.Message

  def handle_packets(messages, state) do
    messages
    |> Enum.filter(&Message.Checksum.verify_checksum/1)
    |> Enum.reduce_while({:ok, state}, fn message, {:ok, state} ->
      case Workflow.handle_payload(message.payload, state) do
        {:error, reason, {:ok, state}} ->
          {:halt, {:error, reason, state}}

        {:ok, state} ->
          {:cont, {:ok, state}}
      end
    end)
  end

  def chunk(binary, messages \\ []) do
    case Message.parse(binary) do
      {:ok, message, rest} ->
        chunk(rest, messages ++ [message])

      {:error, _reason} ->
        IO.puts("reason #{inspect(_reason)}")
        {messages, binary}
    end
  end
end
