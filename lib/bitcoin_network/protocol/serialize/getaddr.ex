defimpl BitcoinNetwork.Protocol.Serialize, for: BitcoinNetwork.Protocol.GetAddr do
  def serialize(_getaddr),
    do: <<>>
end
