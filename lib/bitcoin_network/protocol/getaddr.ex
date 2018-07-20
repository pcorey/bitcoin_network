defmodule BitcoinNetwork.Protocol.GetAddr do
  defstruct []

  alias BitcoinNetwork.Protocol.GetAddr

  def parse(<<>>),
    do: {:ok, %GetAddr{}, <<>>}

  def parse(_binary),
    do: {:error, :bad_get_addr}
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.GetAddr do
  def serialize(_getaddr),
    do: <<>>
end
