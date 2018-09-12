defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.Int32T do
  def serialize(%{value: value}),
    do: <<value::little-integer-signed-32>>
end
