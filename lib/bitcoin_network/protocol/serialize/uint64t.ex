defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.UInt64T do
  def serialize(%{value: value}),
    do: <<value::little-integer-unsigned-64>>
end
