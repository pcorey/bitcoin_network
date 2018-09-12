defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.Message do
  def serialize(message),
    do:
      [
        message.magic,
        message.command,
        message.size,
        message.checksum,
        message.payload
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
