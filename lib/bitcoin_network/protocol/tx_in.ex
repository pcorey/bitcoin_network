defmodule BitcoinNetwork.Protocol.TxIn do
  alias BitcoinNetwork.Protocol.{Outpoint, TxIn, VarInt}

  defstruct previous_output: nil,
            script_length: nil,
            signature_script: nil,
            sequence: nil

  def parse(binary) do
    with {:ok, previous_output, rest} <- parse_previous_output(binary),
         {:ok, script_length, rest} <- parse_script_length(rest),
         {:ok, signature_script, rest} <-
           parse_signature_script(rest, script_length),
         {:ok, sequence, rest} <- parse_sequence(rest) do
      {:ok,
       %TxIn{
         previous_output: previous_output,
         script_length: script_length,
         signature_script: signature_script,
         sequence: sequence
       }, rest}
    end
  end

  defp parse_previous_output(binary),
    do: Outpoint.parse(binary)

  defp parse_script_length(binary) do
    with {:ok, %VarInt{value: script_length}, rest} <- VarInt.parse(binary) do
      {:ok, script_length, rest}
    end
  end

  defp parse_signature_script(binary, script_length) do
    with <<signature_script::binary-size(script_length), rest::binary>> <-
           binary do
      {:ok, signature_script, rest}
    else
      _ -> {:bad_signature_script}
    end
  end

  defp parse_sequence(<<sequence::32-little, rest::binary>>),
    do: {:ok, sequence, rest}

  defp parse_sequence(_binary),
    do: {:error, :bad_sequence}
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.TxIn do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.VarInt

  def serialize(tx),
    do: <<
      serialize_previous_output(tx)::binary,
      serialize_script_length(tx)::binary,
      serialize_signature_script(tx)::binary,
      serialize_sequence(tx)::binary
    >>

  defp serialize_previous_output(%{previous_output: previous_output}),
    do: Protocol.serialize(previous_output)

  defp serialize_script_length(%{script_length: script_length}),
    do: Protocol.serialize(%VarInt{value: script_length})

  defp serialize_signature_script(%{signature_script: signature_script}),
    do: signature_script

  defp serialize_sequence(%{sequence: sequence}),
    do: <<sequence::32-little>>
end
