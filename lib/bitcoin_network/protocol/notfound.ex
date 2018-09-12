defmodule BitcoinNetwork.Protocol.NotFound do
  defstruct count: nil,
            inventory: nil

  alias BitcoinNetwork.Protocol.{
    InvVect,
    NotFound,
    Parse,
    VarInt
  }

  import BitcoinNetwork.Protocol.Value, only: [value: 1]

  def command(),
    do: "notfound"

  def parse(binary, _count) do
    with {:ok, count, rest} <- Parse.parse(VarInt, binary),
         {:ok, inventory, rest} <- Parse.parse(InvVect, rest, value(count)),
         do:
           {:ok,
            %NotFound{
              count: count,
              inventory: inventory
            }, rest}
  end
end
