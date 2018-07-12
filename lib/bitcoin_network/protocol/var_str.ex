defmodule BitcoinNetwork.Protocol.VarStr do
  defstruct value: nil

  alias BitcoinNetwork.Protocol.VarInt
  alias BitcoinNetwork.Protocol.VarStr

  def parse(binary) do
    with {:ok, length, rest} <- parse_length(binary),
         {:ok, value, rest} <- parse_value(rest, length) do
      {:ok, %VarStr{value: value}, rest}
    end
  end

  defp parse_length(binary) do
    with {:ok, %VarInt{value: length}, rest} <- VarInt.parse(binary) do
      {:ok, length, rest}
    end
  end

  defp parse_value(binary, length) do
    with <<value::binary-size(length), rest::binary>> <- binary do
      {:ok, value, rest}
    else
      _ -> {:error, :bad_length}
    end
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.VarStr do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.VarInt

  def serialize(var_str) do
    <<
      serialize_length(var_str)::binary,
      var_str.value::binary
    >>
  end

  defp serialize_length(%{value: value}),
    do: Protocol.serialize(%VarInt{value: String.length(value)})
end
