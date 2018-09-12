defmodule BitcoinNetwork.Protocol.UInt16T do
  defstruct value: nil

  alias BitcoinNetwork.Protocol.UInt16T

  def parse(<<value::little-unsigned-integer-16, rest::binary>>),
    do: {:ok, %UInt16T{value: value}, rest}

  def new(<<value::little-unsigned-integer-16>>),
    do: %UInt16T{value: value}

  def new(value) when is_number(value),
    do: %UInt16T{value: value}
end
