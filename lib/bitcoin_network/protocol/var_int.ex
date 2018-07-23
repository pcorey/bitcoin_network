defmodule BitcoinNetwork.Protocol.VarInt do
  defstruct value: nil

  alias BitcoinNetwork.Protocol.VarInt

  def parse(binary) do
    with {:ok, value, rest} <- parse_value(binary) do
      {:ok, %VarInt{value: value}, rest}
    end
  end

  def parse_value(<<0xFD, value::16-little, rest::binary>>),
    do: {:ok, value, rest}

  def parse_value(<<0xFE, value::32-little, rest::binary>>),
    do: {:ok, value, rest}

  def parse_value(<<0xFF, value::64-little, rest::binary>>),
    do: {:ok, value, rest}

  def parse_value(<<value::8-little, rest::binary>>),
    do: {:ok, value, rest}

  def parse_value(_binary),
    do: {:error, :bad_value}
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.VarInt do
  alias BitcoinNetwork.Protocol.VarInt

  def serialize(%VarInt{value: value}) when value < 0xFD,
    do: <<value::8-little>>

  def serialize(%VarInt{value: value}) when value < 0xFFFF,
    do: <<0xFD, value::16-little>>

  def serialize(%VarInt{value: value}) when value < 0xFFFFFFFF,
    do: <<0xFE, value::32-little>>

  def serialize(%VarInt{value: value}),
    do: <<0xFF, value::64-little>>
end
