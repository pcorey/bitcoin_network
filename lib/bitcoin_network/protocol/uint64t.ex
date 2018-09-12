defmodule BitcoinNetwork.Protocol.UInt64T do
  defstruct value: nil

  alias BitcoinNetwork.Protocol.UInt64T

  def parse(<<value::little-unsigned-integer-64, rest::binary>>),
    do: {:ok, %UInt64T{value: value}, rest}

  def new(<<value::little-unsigned-integer-64>>),
    do: %UInt64T{value: value}

  def new(value) when is_number(value),
    do: %UInt64T{value: value}
end
