defmodule BitcoinNetwork.Protocol.NetAddr do
  defstruct time: nil, services: nil, ip: nil, port: nil

  alias BitcoinNetwork.Protocol.NetAddr

  def parse(
        <<time::32-little, services::64-little, ip::binary-size(16), port::16-big, rest::binary>>
      ) do
    {:ok, %NetAddr{time: time, services: services, ip: ip, port: port}, rest}
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.NetAddr do
  alias BitcoinNetwork.Protocol.NetAddr

  def serialize(%NetAddr{time: time, services: services, ip: ip, port: port}) do
    <<services::64-little, :binary.decode_unsigned(ip)::128-big, port::16-big>>
  end
end
