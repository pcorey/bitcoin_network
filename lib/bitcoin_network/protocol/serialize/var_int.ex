defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.VarInt do
  def serialize(var_int),
    do:
      [
        var_int.prefix,
        var_int.value
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
