defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.Block do
  def serialize(block),
    do:
      [
        block.version,
        block.prev_block,
        block.merkle_root,
        block.timestamp,
        block.bits,
        block.nonce,
        block.tx_count,
        block.txs
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
