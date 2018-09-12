defmodule BitcoinNetwork.Protocol.UInt8T do
  defstruct value: nil

  alias BitcoinNetwork.Protocol.UInt8T

  def parse(<<value::little-unsigned-integer-8, rest::binary>>),
    do: {:ok, %UInt8T{value: value}, rest}

  def new(<<value::little-unsigned-integer-8>>),
    do: %UInt8T{value: value}

  def new(value) when is_number(value),
    do: %UInt8T{value: value}
end
