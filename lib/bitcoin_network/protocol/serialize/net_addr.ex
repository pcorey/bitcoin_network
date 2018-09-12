defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.NetAddr do
  def serialize(net_addr),
    do:
      [
        net_addr.time,
        net_addr.services,
        net_addr.ip,
        net_addr.port
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
