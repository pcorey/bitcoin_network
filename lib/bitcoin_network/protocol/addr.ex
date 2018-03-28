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
       }}
    else
      _ -> nil
    end
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Addr do
  alias BitcoinNetwork.Protocol.Addr

  # TODO: Do this...
  def serialize(%Addr{addr_list: addr_list}) do
    <<>>
  end
end
