defmodule BitcoinNetwork.Protocol.VarInt do
  defstruct value: nil

  alias BitcoinNetwork.Protocol.VarInt

  def parse(<<0xFD, value::16-little, rest::binary>>) do
    {:ok, %VarInt{value: value}, rest}
  end

  def parse(<<0xFE, value::32-little, rest::binary>>) do
    {:ok, %VarInt{value: value}, rest}
  end

  def parse(<<0xFF, value::64-little, rest::binary>>) do
    {:ok, %VarInt{value: value}, rest}
  end

  def parse(<<value::8-little, rest::binary>>) do
    {:ok, %VarInt{value: value}, rest}
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.VarInt do
  alias BitcoinNetwork.Protocol.VarInt

  def serialize(%VarInt{value: value}) when value < 0xFD do
    <<value::8-little>>
  end

  def serialize(%VarInt{value: value}) when value < 0xFFFF do
    <<0xFD, value::16-little>>
  end

  def serialize(%VarInt{value: value}) when value < 0xFFFFFFFF do
    <<0xFE, value::32-little>>
  end

  def serialize(%VarInt{value: value}) do
    <<0xFF, value::64-little>>
  end
end
