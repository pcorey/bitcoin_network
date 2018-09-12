defmodule BitcoinNetwork.Protocol.VersionNetAddr do
  defstruct services: nil,
            ip: nil,
            port: nil

  alias BitcoinNetwork.Protocol.{
    IP,
    VersionNetAddr,
    UInt64T,
    UInt16T
  }

  def parse(binary) do
    with {:ok, services, rest} <- UInt64T.parse(binary),
         {:ok, ip, rest} <- IP.parse(rest),
         {:ok, port, rest} <- UInt16T.parse(rest),
         do:
           {:ok,
            %VersionNetAddr{
              services: services,
              ip: ip,
              port: port
            }, rest}
  end

  def new(ip, port, services),
    do: %VersionNetAddr{
      ip: IP.new(ip),
      port: UInt16T.new(port),
      services: UInt64T.new(services)
    }
end
