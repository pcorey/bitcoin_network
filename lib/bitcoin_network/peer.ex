defmodule BitcoinNetwork.Peer do
  alias BitcoinNetwork.Protocol.Message

  def send(message, socket) do
    with serialized <- Message.serialize(message),
         :ok <- :gen_tcp.send(socket, serialized) do
      {:ok, serialized}
    end
  end
end
