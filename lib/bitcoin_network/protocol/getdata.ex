defmodule BitcoinNetwork.Protocol.GetData do
  defstruct count: nil,
            inventory: nil

  alias BitcoinNetwork.Protocol.{
    GetData,
    InvVect,
    Parse,
    VarInt
  }

  import BitcoinNetwork.Protocol.Value, only: [value: 1]

  def command(),
    do: "getdata"

  def parse(binary, _count) do
    with {:ok, count, rest} <- Parse.parse(VarInt, binary),
         {:ok, inventory, rest} <- Parse.parse(InvVect, rest, value(count)),
         do:
           {:ok,
            %GetData{
              count: count,
              inventory: inventory
            }, rest}
  end
end
