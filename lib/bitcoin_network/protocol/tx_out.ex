defmodule BitcoinNetwork.Protocol.TxOut do
  alias BitcoinNetwork.Protocol.{TxOut, VarInt}

  defstruct value: nil,
            pk_script_length: nil,
            pk_script: nil

  def parse(binary) do
    with {:ok, value, rest} <- parse_value(binary),
         {:ok, pk_script_length, rest} <- parse_pk_script_length(rest),
         {:ok, pk_script, rest} <- parse_pk_script(rest, pk_script_length) do
      {:ok,
       %TxOut{
         value: value,
         pk_script_length: pk_script_length,
         pk_script: pk_script
       }, rest}
    end
  end

  defp parse_value(<<value::64-little, rest::binary>>),
    do: {:ok, value, rest}

  defp parse_value(_binary),
    do: {:error, :bad_value}

  defp parse_pk_script_length(binary) do
    with {:ok, %VarInt{value: pk_script_length}, rest} <- VarInt.parse(binary) do
      {:ok, pk_script_length, rest}
    end
  end

  defp parse_pk_script(binary, pk_script_length) do
    with <<pk_script::binary-size(pk_script_length), rest::binary>> <- binary do
      {:ok, pk_script, rest}
    else
      _ -> {:bad_pk_script}
    end
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.TxOut do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.VarInt

  def serialize(tx),
    do: <<
      serialize_value(tx)::binary,
      serialize_pk_script_length(tx)::binary,
      serialize_pk_script(tx)::binary
    >>

  defp serialize_value(%{value: value}),
    do: <<value::64-little>>

  defp serialize_pk_script_length(%{pk_script_length: pk_script_length}),
    do: Protocol.serialize(%VarInt{value: pk_script_length})

  defp serialize_pk_script(%{pk_script: pk_script}),
    do: pk_script
end
