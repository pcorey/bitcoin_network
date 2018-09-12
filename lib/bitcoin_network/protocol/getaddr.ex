defmodule BitcoinNetwork.Protocol.GetAddr do
  defstruct []

  alias BitcoinNetwork.Protocol.GetAddr

  def command(),
    do: "getaddr"

  def parse(binary),
    do: {:ok, %GetAddr{}, binary}
end
