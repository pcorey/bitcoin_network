defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.Inv do
  def serialize(inv),
    do:
      [
        inv.count,
        inv.inventory
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
