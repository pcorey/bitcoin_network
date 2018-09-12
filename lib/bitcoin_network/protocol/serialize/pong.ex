defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.Pong do
  def serialize(pong),
    do:
      [
        pong.nonce
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
