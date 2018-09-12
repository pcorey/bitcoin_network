defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.IP do
  def serialize(%{value: value}),
    do: value
end
