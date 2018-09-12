defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.InvVect do
  def serialize(inv_vect),
    do:
      [
        inv_vect.type,
        inv_vect.hash
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
