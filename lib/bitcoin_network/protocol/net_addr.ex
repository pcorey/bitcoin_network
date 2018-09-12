defmodule BitcoinNetwork.Protocol.NetAddr do
  defstruct time: nil,
            services: nil,
            ip: nil,
            port: nil

  alias BitcoinNetwork.Protocol.{IP, NetAddr, UInt32T, UInt64T, UInt16T}

  def parse(binary) do
    with {:ok, time, rest} <- UInt32T.parse(binary),
         {:ok, services, rest} <- UInt64T.parse(rest),
         {:ok, ip, rest} <- IP.parse(rest),
         {:ok, port, rest} <- UInt16T.parse(rest),
         do:
           {:ok,
            %NetAddr{
              time: time,
              services: services,
              ip: ip,
              port: port
            }, rest}
  end
end
