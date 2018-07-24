defmodule BitcoinNetwork.Protocol.TxWitnessComponent do
  alias BitcoinNetwork.Protocol.{TxWitnessComponent, VarInt}

  defstruct length: nil,
            data: nil

  def parse(binary) do
    with {:ok, length, rest} <- parse_length(binary),
         {:ok, data, rest} <- parse_data(rest, length) do
      {:ok, %TxWitnessComponent{length: length, data: data}, rest}
    end
  end

  defp parse_length(binary) do
    with {:ok, %VarInt{value: length}, rest} <- VarInt.parse(binary) do
      {:ok, length, rest}
    end
  end

  defp parse_data(binary, length) do
    with <<data::binary-size(length), rest::binary>> <- binary do
      {:ok, data, rest}
    else
      _ -> {:error, :bad_data}
    end
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.TxWitnessComponent do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.VarInt

  def serialize(tx_witness_component),
    do: <<
      serialize_length(tx_witness_component)::binary,
      serialize_data(tx_witness_component)::binary
    >>

  defp serialize_length(%{length: length}),
    do: Protocol.serialize(%VarInt{value: length})

  defp serialize_data(%{data: data}),
    do: data
end
