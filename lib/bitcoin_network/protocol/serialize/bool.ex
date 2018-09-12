defimpl BitcoinNetwork.Protocol.Serialize, for: Atom do
  def serialize(true),
    do: <<1>>

  def serialize(false),
    do: <<0>>
end
