defimpl BitcoinNetwork.Protocol.Serialize, for: BitString do
  def serialize(byte),
    do: byte
end
