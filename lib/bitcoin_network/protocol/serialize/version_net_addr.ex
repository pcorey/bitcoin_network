defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.VersionNetAddr do
  def serialize(net_addr),
    do:
      [
        net_addr.services,
        net_addr.ip,
        net_addr.port
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
