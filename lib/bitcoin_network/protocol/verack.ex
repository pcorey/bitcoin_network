defmodule BitcoinNetwork.Protocol.Verack do
  defstruct []

  alias BitcoinNetwork.Protocol.Verack

  def command(),
    do: "verack"

  def parse(binary),
    do: {:ok, %Verack{}, binary}
end
