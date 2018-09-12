defimpl BitcoinNetwork.Protocol.Serialize, for: List do
  def serialize(array),
    do:
      array
      |> Enum.map(&BitcoinNetwork.Protocol.Serialize.serialize/1)
      |> join()

  def join(pieces),
    do: Enum.reduce(pieces, <<>>, fn piece, binary -> <<binary::binary, piece::binary>> end)
end
