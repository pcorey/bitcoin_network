defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.GetData do
  def serialize(get_data),
    do:
      [
        get_data.count,
        get_data.inventory
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
