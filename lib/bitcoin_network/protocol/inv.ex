defmodule BitcoinNetwork.Protocol.Inv do
  alias BitcoinNetwork.Protocol.{Inv, InvVect, VarInt}

  defstruct count: nil,
            inventory: nil

  def parse(binary) do
    with {:ok, count, rest} <- parse_count(binary),
         {:ok, inventory, rest} <- parse_inventory(rest) do
      {:ok, %Inv{count: count, inventory: inventory}, rest}
    end
  end

  defp parse_count(binary) do
    with {:ok, %VarInt{value: count}, rest} <- VarInt.parse(binary) do
      {:ok, count, rest}
    end
  end

  defp parse_inventory(binary, inventory \\ [])

  defp parse_inventory(binary, inventory) when byte_size(binary) < 36,
    do: {:ok, inventory, binary}

  defp parse_inventory(binary, inventory) do
    with {:ok, inv, rest} <- InvVect.parse(binary) do
      parse_inventory(rest, inventory ++ [inv])
    end
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Inv do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.VarInt

  def serialize(inv_vect),
    do: <<
      serialize_count(inv_vect)::binary,
      serialize_inventory(inv_vect)::binary
    >>

  defp serialize_count(%{count: count}),
    do: Protocol.serialize(%VarInt{value: count})

  defp serialize_inventory(%{inventory: inventory}),
    do:
      inventory
      |> Enum.map(&Protocol.serialize/1)
      |> Enum.join()
end
