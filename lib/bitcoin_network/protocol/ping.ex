defmodule BitcoinNetwork.Protocol.Ping do
  defstruct []

  alias BitcoinNetwork.Protocol.Ping

  def parse(<<>>) do
    {:ok, %Ping{}, <<>>}
  end
end
