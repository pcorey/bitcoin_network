defmodule BitcoinNetwork.Protocol.Bool do
  def parse(<<1, rest::binary>>),
    do: {:ok, true, rest}

  def parse(<<0, rest::binary>>),
    do: {:ok, false, rest}

  def new(true),
    do: <<1>>

  def new(false),
    do: <<0>>
end
