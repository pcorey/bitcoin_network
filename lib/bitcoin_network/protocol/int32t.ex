defmodule BitcoinNetwork.Protocol.Int32T do
  defstruct value: nil

  alias BitcoinNetwork.Protocol.Int32T

  def parse(<<value::32-little, rest::binary>>),
    do: {:ok, %Int32T{value: value}, rest}

  def new(<<value::little-signed-integer-32>>),
    do: %Int32T{value: value}

  def new(value) when is_number(value),
    do: %Int32T{value: value}
end
