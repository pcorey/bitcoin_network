defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.UInt8T do
  def serialize(%{value: value}),
    do: <<value::little-integer-unsigned-8>>
end
