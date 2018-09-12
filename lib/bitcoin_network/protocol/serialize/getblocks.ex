defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.GetBlocks do
  def serialize(get_blocks),
    do:
      [
        get_blocks.version,
        get_blocks.hash_count,
        get_blocks.block_locator_hashes,
        get_blocks.hash_stop
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
