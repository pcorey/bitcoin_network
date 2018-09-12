defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.Addr do
  def serialize(addr),
    do:
      [
        addr.count,
        addr.addr_list
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
