defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.NotFound do
  def serialize(not_found),
    do:
      [
        not_found.count,
        not_found.inventory
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
