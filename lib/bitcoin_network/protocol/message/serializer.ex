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

  def serialize(payload = %Addr{}),
    do: {:ok, serialize("addr", payload)}

  def serialize(payload = %GetAddr{}),
    do: {:ok, serialize("getaddr", payload)}

  def serialize(payload = %Ping{}),
    do: {:ok, serialize("ping", payload)}

  def serialize(payload = %Pong{}),
    do: {:ok, serialize("pong", payload)}

  def serialize(payload = %Verack{}),
    do: {:ok, serialize("verack", payload)}

  def serialize(payload = %Version{}),
    do: {:ok, serialize("version", payload)}

  def serialize(_payload),
    do: {:error, :unrecognized_payload}

  def serialize(command, payload) when is_binary(payload),
    do:
      Protocol.serialize(%Message{
        command: command,
        payload: payload
      })

  def serialize(command, payload),
    do:
      Protocol.serialize(%Message{
        command: command,
        payload: Protocol.serialize(payload)
      })
end
