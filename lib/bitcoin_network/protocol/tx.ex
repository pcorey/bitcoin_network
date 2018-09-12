defmodule BitcoinNetwork.Protocol.Tx do
  defstruct version: nil,
            flag: nil,
            tx_in_count: nil,
            tx_in: nil,
            tx_out_count: nil,
            tx_out: nil,
            tx_witnesses: nil,
            lock_time: nil

  alias BitcoinNetwork.Protocol.{
    Int32T,
    Parse,
    Tx,
    TxIn,
    TxOut,
    TxWitness,
    WitnessFlag
  }

  import BitcoinNetwork.Protocol.Value, only: [value: 1]

  import BitcoinNetwork.Protocol.Value, only: [value: 1]

  def command(),
    do: "tx"

  def parse(binary) do
    with {:ok, version, rest} <- Int32T.parse(binary),
         {:ok, flag, rest} <- WitnessFlag.parse(rest),
         {:ok, tx_in_count, rest} <- VarInt.parse(rest),
         {:ok, tx_in, rest} <- TxIn.parse(rest, value(tx_in_count)),
         {:ok, tx_out_count, rest} <- VarInt.parse(rest),
         {:ok, tx_out, rest} <- TxOut.parse(rest, value(tx_out_count)),
         {:ok, tx_witnesses, rest} <- parse_tx_witness(flag, rest),
         {:ok, lock_time, rest} <- UInt32T.parse(rest),
         do:
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

  defp parse_tx_witness(flag, rest) do
    if value(flag) do
      TxWitness.parse(rest)
    else
      []
    end
  end
end
