defmodule BitcoinNetwork.Protocol.Verack do
  defstruct []

  alias BitcoinNetwork.Protocol.Verack

  def parse(<<>>) do
    {:ok, %Verack{}, <<>>}
  end
end
