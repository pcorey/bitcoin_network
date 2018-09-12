defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.Tx do
  def serialize(tx),
    do:
      [
        tx.version,
        tx.flag,
        tx.tx_in_count,
        tx.tx_in,
        tx.tx_out_count,
        tx.tx_out,
        tx.tx_witness,
        tx.lock_time
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
