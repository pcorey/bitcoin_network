defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.Ping do
  def serialize(ping),
    do:
      [
        ping.nonce
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
