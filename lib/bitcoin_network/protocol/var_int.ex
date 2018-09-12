defmodule BitcoinNetwork.Protocol.VarInt do
  defstruct prefix: nil,
            value: nil

  alias BitcoinNetwork.Protocol.{
    Binary,
    UInt16T,
    UInt32T,
    UInt64T,
    UInt8T,
    VarInt
  }

  def parse(<<0xFF, binary::binary>>) do
    with {:ok, value, rest} <- UInt64T.parse(binary),
         do: {:ok, %VarInt{prefix: <<0xFF>>, value: value}, rest}
  end

  def parse(<<0xFE, binary::binary>>) do
    with {:ok, value, rest} <- UInt32T.parse(binary),
         do: {:ok, %VarInt{prefix: <<0xFE>>, value: value}, rest}
  end

  def parse(<<0xFD, binary::binary>>) do
    with {:ok, value, rest} <- UInt16T.parse(binary),
         do: {:ok, %VarInt{prefix: <<0xFD>>, value: value}, rest}
  end

  def parse(<<binary::binary>>) do
    with {:ok, value, rest} <- UInt8T.parse(binary),
         do: {:ok, %VarInt{prefix: <<>>, value: value}, rest}
  end

  def new(value) when value < 0xFD,
    do: %VarInt{
      prefix: Binary.new(<<>>),
      value: UInt8T.new(value)
    }

  def new(value) when value <= 0xFFFF,
    do: %VarInt{
      prefix: Binary.new(<<0xFD>>),
      value: UInt16T.new(value)
    }

  def new(value) when value <= 0xFFFFFFFF,
    do: %VarInt{
      prefix: Binary.new(<<0xFE>>),
      value: UInt32T.new(value)
    }

  def new(value),
    do: %VarInt{
      prefix: Binary.new(<<0xFF>>),
      value: UInt64T.new(value)
    }
end
