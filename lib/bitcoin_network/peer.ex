defmodule BitcoinNetwork.Peer do
  alias BitcoinNetwork.Protocol.Message

  def send(message, socket),
    do: :gen_tcp.send(socket, Message.serialize(message))
end
