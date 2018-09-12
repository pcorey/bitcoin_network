defmodule BitcoinNetwork.Protocol.Value do
  def value(%{value: value}),
    do: value(value)

  def value(value),
    do: value
end
