defmodule BitcoinNetwork.Protocol.Inv do
  defstruct count: nil,
            inventory: nil

  alias BitcoinNetwork.Protocol.{
    Array,
    Inv,
    InvVect,
    Parse,
    VarInt
  }

  import BitcoinNetwork.Protocol.Value, only: [value: 1]

  def command(),
    do: "inv"

  def parse(binary) do
    with {:ok, count, rest} <- VarInt.parse(binary),
         {:ok, inventory, rest} <- Array.parse(rest, value(count), &InvVect.parse/1),
         do:
           {:ok,
            %Inv{
              count: count,
              inventory: inventory
            }, rest}
  end
end
