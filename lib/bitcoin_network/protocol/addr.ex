defmodule BitcoinNetwork.Protocol.Addr do
  defstruct addr_list: nil

  alias BitcoinNetwork.Protocol.{Addr, NetAddr, VarInt}

  def parse(binary) do
    with {:ok, %VarInt{value: count}, rest} <- VarInt.parse(binary) do
      {:ok, count}
      # {:ok,
      #  %Addr{
      #    addr_list:
      #      Enum.reduce(rest, fn rest, addr_list ->
      #        with <<timestamp::32-little>> <- rest,
      #             {:ok,
      #              net_addr = %NetAddr{
      #                services: services,
      #                ip: recv_ip,
      #                port: recv_port
      #              }, rest} <- NetAddr.parse(rest) do
      #          {timestamp, net_addr}
      #        end
      #      end)
      #  }}
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
