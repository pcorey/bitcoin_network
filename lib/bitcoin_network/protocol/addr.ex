defmodule BitcoinNetwork.Protocol.Addr do
  defstruct addr_list: nil

  alias BitcoinNetwork.Protocol.{Addr, NetAddr, VarInt}

  def parse(binary) do
    with {:ok, %VarInt{value: count}, rest} <- VarInt.parse(binary) do
      {:ok,
       %Addr{
         addr_list: chunk(rest)
       }}
    else
      _ -> nil
    end
  end

  def chunk(binary, addr_list \\ [])

  def chunk(<<>>, addr_list), do: addr_list

  def chunk(binary, addr_list) do
    with {:ok, net_addr = %NetAddr{services: services, ip: recv_ip, port: recv_port}, rest} <-
           NetAddr.parse(binary) do
      chunk(rest, addr_list ++ [net_addr])
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
