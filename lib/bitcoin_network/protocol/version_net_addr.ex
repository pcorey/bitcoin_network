defmodule BitcoinNetwork.Protocol.VersionNetAddr do
  defstruct services: nil, ip: nil, port: nil

  alias BitcoinNetwork.Protocol.VersionNetAddr

  def parse(<<services::64-little, ip::128-big, port::16-big, rest::binary>>) do
    {:ok, %VersionNetAddr{services: services, ip: ip, port: port}, rest}
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.VersionNetAddr do
  alias BitcoinNetwork.Protocol.VersionNetAddr

  def serialize(%VersionNetAddr{services: services, ip: ip, port: port}) do
    <<services::64-little, :binary.decode_unsigned(ip)::128-big, port::16-big>>
  end
end
