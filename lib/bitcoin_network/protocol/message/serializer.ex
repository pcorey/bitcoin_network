defmodule BitcoinNetwork.Protocol.Message.Serializer do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.Message

  alias BitcoinNetwork.Protocol.{
    Addr,
    GetAddr,
    Message,
    Ping,
    Pong,
    Verack,
    Version
  }

  def serialize(payload = %Addr{}), do: serialize("addr", payload)
  def serialize(payload = %GetAddr{}), do: serialize("getaddr", payload)
  def serialize(payload = %Ping{}), do: serialize("ping", payload)
  def serialize(payload = %Pong{}), do: serialize("pong", payload)
  def serialize(payload = %Verack{}), do: serialize("verack", payload)
  def serialize(payload = %Version{}), do: serialize("version", payload)

  def serialize(command, payload) when is_binary(payload) do
    Protocol.serialize(%Message{
      command: command,
      payload: payload
    })
  end

  def serialize(command, payload) do
    Protocol.serialize(%Message{
      command: command,
      payload: Protocol.serialize(payload)
    })
  end
end
