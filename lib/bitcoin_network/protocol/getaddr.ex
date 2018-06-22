defmodule BitcoinNetwork.Protocol.GetAddr do
  defstruct []

  alias BitcoinNetwork.Protocol.GetAddr

  def parse(<<>>) do
    {:ok, %GetAddr{}, <<>>}
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.GetAddr do
  def serialize(_getaddr) do
    <<>>
  end
end
