defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.VarStr do
  def serialize(var_int),
    do:
      [
        var_int.length,
        var_int.value
      ]
      |> BitcoinNetwork.Protocol.Serialize.serialize()
end
