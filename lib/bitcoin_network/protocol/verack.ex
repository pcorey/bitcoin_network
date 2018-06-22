defmodule BitcoinNetwork.Protocol.Verack do
  defstruct []

  alias BitcoinNetwork.Protocol.Verack

  def parse(<<>>) do
    {:ok, %Verack{}, <<>>}
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Verack do
  def serialize(_verack) do
    <<>>
  end
end
