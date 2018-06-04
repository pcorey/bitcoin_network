defmodule BitcoinNetwork.Protocol.Addr do
  defstruct count: nil, addr_list: nil

  alias BitcoinNetwork.Protocol.{Addr, NetAddr, VarInt}

  def parse(binary) do
    with {:ok, %VarInt{value: count}, rest} <- VarInt.parse(binary) do
      {:ok,
       %Addr{
         count: count,
         addr_list:
           for <<binary::binary-size(30) <- rest>> do
             {:ok, net_addr, _rest} = NetAddr.parse(binary)
             net_addr
           end
       }, <<>>}
    else
      _err -> nil
    end
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Addr do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.{Addr, VarInt}

  def serialize(%Addr{count: count, addr_list: addr_list}) do
    <<
      Protocol.serialize(%VarInt{value: count})::binary,
      addr_list
      |> Enum.map(&Protocol.serialize/1)
      |> Enum.join()::binary
    >>
  end
end
