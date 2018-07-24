defmodule BitcoinNetwork.Protocol.Message.Serializer do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.Message

  alias BitcoinNetwork.Protocol.{
    Addr,
    Inv,
    InvVect,
    GetAddr,
    GetData,
    Message,
    NotFound,
    Ping,
    Pong,
    Tx,
    Verack,
    Version
  }

  def serialize(payload = %Addr{}),
    do: {:ok, serialize("addr", payload)}

  def serialize(payload = %GetAddr{}),
    do: {:ok, serialize("getaddr", payload)}

  def serialize(payload = %GetData{}),
    do: {:ok, serialize("getdata", payload)}

  def serialize(payload = %Inv{}),
    do: {:ok, serialize("inv", payload)}

  def serialize(payload = %InvVect{}),
    do: {:ok, serialize("inv_vect", payload)}

  def serialize(payload = %NotFound{}),
    do: {:ok, serialize("notfound", payload)}

  def serialize(payload = %Ping{}),
    do: {:ok, serialize("ping", payload)}

  def serialize(payload = %Pong{}),
    do: {:ok, serialize("pong", payload)}

  def serialize(payload = %Tx{}),
    do: {:ok, serialize("tx", payload)}

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
