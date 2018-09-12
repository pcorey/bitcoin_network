defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.Version do
  def serialize(version),
    do:
      [
        version.version,
        version.services,
        version.timestamp,
        version.addr_recv,
        version.addr_from,
        version.nonce,
        version.user_agent,
        version.start_height,
        version.relay
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
