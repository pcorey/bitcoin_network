defmodule BitcoinNetwork.Protocol.Tx do
  alias BitcoinNetwork.Protocol.{Tx, InvVect, TxIn, TxOut, TxWitness, VarInt}

  defstruct version: nil,
            flag: nil,
            tx_in_count: nil,
            tx_in: nil,
            tx_out_count: nil,
            tx_out: nil,
            tx_witnesses: nil,
            lock_time: nil

  def parse(binary) do
    with {:ok, version, rest} <- parse_version(binary),
         {:ok, flag, rest} <- parse_flag(rest),
         {:ok, tx_in_count, rest} <- parse_tx_in_count(rest),
         {:ok, tx_in, rest} <- parse_tx_in(rest, tx_in_count),
         {:ok, tx_out_count, rest} <- parse_tx_out_count(rest),
         {:ok, tx_out, rest} <- parse_tx_out(rest, tx_out_count),
         {:ok, tx_witnesses, rest} <-
           parse_tx_witnesses(rest, tx_in_count, flag),
         {:ok, lock_time, rest} <- parse_lock_time(rest) do
      {:ok,
       %Tx{
         version: version,
         flag: flag,
         tx_in_count: tx_in_count,
         tx_in: tx_in,
         tx_out_count: tx_out_count,
         tx_out: tx_out,
         tx_witnesses: tx_witnesses,
         lock_time: lock_time
       }, rest}
    end
  end

  defp parse_version(<<version::32-little, rest::binary>>),
    do: {:ok, version, rest}

  defp parse_version(_binary),
    do: {:error, :bad_version}

  defp parse_flag(<<0x00, 0x02, rest::binary>>),
    do: {:ok, 2, rest}

  defp parse_flag(rest),
    do: {:ok, 0, rest}

  defp parse_tx_in_count(binary) do
    with {:ok, %VarInt{value: tx_in_count}, rest} <- VarInt.parse(binary) do
      {:ok, tx_in_count, rest}
    end
  end

  defp parse_tx_in(binary, tx_in_count, tx_in \\ [])

  defp parse_tx_in(binary, tx_in_count, tx_in) when tx_in_count == 0,
    do: {:ok, tx_in, binary}

  defp parse_tx_in(binary, tx_in_count, tx_in) do
    with {:ok, tx, rest} <- TxIn.parse(binary) do
      parse_tx_in(rest, tx_in_count - 1, tx_in ++ [tx])
    end
  end

  defp parse_tx_out_count(binary) do
    with {:ok, %VarInt{value: tx_out_count}, rest} <- VarInt.parse(binary) do
      {:ok, tx_out_count, rest}
    end
  end

  defp parse_tx_out(binary, tx_out_count, tx_out \\ [])

  defp parse_tx_out(binary, tx_out_count, tx_out) when tx_out_count == 0,
    do: {:ok, tx_out, binary}

  defp parse_tx_out(binary, tx_out_count, tx_out) do
    with {:ok, tx, rest} <- TxOut.parse(binary) do
      parse_tx_out(rest, tx_out_count - 1, tx_out ++ [tx])
    end
  end

  defp parse_tx_witnesses(binary, tx_in_count, flag, tx_witnesses \\ [])

  defp parse_tx_witnesses(binary, tx_in_count, 0, tx_witnesses),
    do: {:ok, [], binary}

  defp parse_tx_witnesses(binary, tx_in_count, flag, tx_witnesses)
       when tx_in_count == 0,
       do: {:ok, tx_witnesses, binary}

  defp parse_tx_witnesses(binary, tx_in_count, flag, tx_witnesses) do
    with {:ok, tx_witness, rest} <- TxWitness.parse(binary) do
      parse_tx_witnesses(rest, tx_in_count - 1, tx_witnesses ++ [tx_witness])
    end
  end

  defp parse_lock_time(<<lock_time::32-little, rest::binary>>),
    do: {:ok, lock_time, rest}

  defp parse_lock_time(_binary),
    do: {:error, :bad_lock_time}
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Tx do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.VarInt

  def serialize(tx),
    do: <<
      serialize_version(tx)::binary,
      serialize_flag(tx)::binary,
      serialize_tx_in_count(tx)::binary,
      serialize_tx_in(tx)::binary,
      serialize_tx_out_count(tx)::binary,
      serialize_tx_out(tx)::binary,
      serialize_tx_witnesses(tx)::binary,
      serialize_lock_time(tx)::binary
    >>

  defp serialize_version(%{version: version}),
    do: <<version::32-little>>

  defp serialize_flag(%{flag: 0}),
    do: <<>>

  defp serialize_flag(%{flag: flag}),
    do: <<flag::16-little>>

  defp serialize_tx_in_count(%{tx_in_count: tx_in_count}),
    do: Protocol.serialize(%VarInt{value: tx_in_count})

  defp serialize_tx_in(%{tx_in: tx_in}),
    do:
      tx_in
      |> Enum.map(&Protocol.serialize/1)
      |> Enum.join()

  defp serialize_tx_out_count(%{tx_out_count: tx_out_count}),
    do: Protocol.serialize(%VarInt{value: tx_out_count})

  defp serialize_tx_out(%{tx_out: tx_out}),
    do:
      tx_out
      |> Enum.map(&Protocol.serialize/1)
      |> Enum.join()

  defp serialize_tx_witnesses(%{tx_witnesses: tx_witnesses}),
    do:
      tx_witnesses
      |> Enum.map(&Protocol.serialize/1)
      |> Enum.join()

  defp serialize_lock_time(%{lock_time: lock_time}),
    do: <<lock_time::32-little>>
end
