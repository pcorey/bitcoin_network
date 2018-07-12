defmodule BitcoinNetwork.Protocol.Addr do
  alias BitcoinNetwork.Protocol.{Addr, NetAddr, VarInt}

  defstruct count: nil,
            addr_list: nil

  def parse(binary) do
    with {:ok, count, rest} <- parse_count(binary),
         {:ok, addr_list, rest} <- parse_addr_list(rest) do
      {:ok, %Addr{count: count, addr_list: addr_list}, rest}
    end
  end

  defp parse_count(binary) do
    with {:ok, %VarInt{value: count}, rest} <- VarInt.parse(binary) do
      {:ok, count, rest}
    end
  end

  defp parse_addr_list(binary, addr_list \\ [])

  defp parse_addr_list(binary, addr_list) when byte_size(binary) < 30,
    do: {:ok, addr_list, binary}

  defp parse_addr_list(binary, addr_list) do
    with {:ok, net_addr, rest} <- NetAddr.parse(binary) do
      parse_addr_list(rest, [net_addr | addr_list])
    end
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Addr do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.{Addr, VarInt}

  def serialize(addr) do
    <<
      serialize_count(addr)::binary,
      serialize_addr_list(addr)::binary
    >>
  end

  defp serialize_count(%{count: count}),
    do: Protocol.serialize(%VarInt{value: count})

  defp serialize_addr_list(%{addr_list: addr_list}),
    do:
      addr_list
      |> Enum.map(&Protocol.serialize/1)
      |> Enum.join()
end
