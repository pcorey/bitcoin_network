defmodule BitcoinNetwork.Protocol.UInt32T do
  defstruct value: nil

  alias BitcoinNetwork.Protocol.UInt32T

  def parse(<<value::little-unsigned-integer-32, rest::binary>>),
    do: {:ok, %UInt32T{value: value}, rest}

  def new(value = %UInt32T{}),
    do: value

  def new(<<value::little-unsigned-integer-32>>),
    do: %UInt32T{value: value}

  def new(value) when is_number(value),
    do: %UInt32T{value: value}
end
