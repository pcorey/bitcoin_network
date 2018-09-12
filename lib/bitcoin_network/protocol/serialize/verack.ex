defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.Verack do
  def serialize(_verack),
    do: <<>>
end
