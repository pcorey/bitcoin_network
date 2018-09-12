defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.UInt16T do
  def serialize(%{value: value}),
    do: <<value::little-integer-unsigned-16>>
end
