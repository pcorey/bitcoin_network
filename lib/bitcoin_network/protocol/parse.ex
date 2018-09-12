defprotocol BitcoinNetwork.Protocol.Parse do
  def parse(module, binary, count \\ 0)
end
