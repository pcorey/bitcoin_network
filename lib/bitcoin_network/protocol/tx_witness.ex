defmodule BitcoinNetwork.Protocol.TxWitness do
  alias BitcoinNetwork.Protocol.{TxWitness, TxWitnessComponent, VarInt}

  defstruct count: nil,
            components: nil

  def parse(binary) do
    with {:ok, count, rest} <- parse_count(binary),
         {:ok, components, rest} <- parse_components(rest, count) do
      {:ok, %TxWitness{count: count, components: components}, rest}
    end
  end

  defp parse_count(binary) do
    with {:ok, %VarInt{value: count}, rest} <- VarInt.parse(binary) do
      {:ok, count, rest}
    end
  end

  defp parse_components(binary, count, components \\ [])

  defp parse_components(binary, count, components) when count == 0,
    do: {:ok, components, binary}

  defp parse_components(binary, count, components) do
    with {:ok, component, rest} <- TxWitnessComponent.parse(binary) do
      parse_components(rest, count - 1, components ++ [component])
    end
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.TxWitness do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.VarInt

  def serialize(tx),
    do: <<
      serialize_count(tx)::binary,
      serialize_components(tx)::binary
    >>

  defp serialize_count(%{count: count}),
    do: Protocol.serialize(%VarInt{value: count})

  defp serialize_components(%{components: components}),
    do:
      components
      |> Enum.map(&Protocol.serialize/1)
      |> Enum.join()
end
