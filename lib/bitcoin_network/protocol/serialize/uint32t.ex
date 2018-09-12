defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.UInt32T do
  def serialize(%{value: value}),
    do: <<value::little-unsigned-integer-32>>
end
