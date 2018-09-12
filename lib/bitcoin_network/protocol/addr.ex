defmodule BitcoinNetwork.Protocol.Addr do
  defstruct count: nil,
            addr_list: nil

  alias BitcoinNetwork.Protocol.{Addr, Array, NetAddr, VarInt}

  import BitcoinNetwork.Protocol.Value, only: [value: 1]

  def command(),
    do: "addr"

  def parse(binary) do
    with {:ok, count, rest} <- VarInt.parse(binary),
         {:ok, addr_list, rest} <- Array.parse(rest, value(count), &NetAddr.parse/1),
         do:
           {:ok,
            %Addr{
              count: count,
              addr_list: addr_list
            }, rest}
  end
end
