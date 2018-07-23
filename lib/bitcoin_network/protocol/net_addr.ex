defmodule BitcoinNetwork.Protocol.NetAddr do
  alias BitcoinNetwork.Protocol.NetAddr

  defstruct time: nil, services: nil, ip: nil, port: nil

  def parse(binary) do
    with {:ok, time, rest} <- parse_time(binary),
         {:ok, services, rest} <- parse_services(rest),
         {:ok, ip, rest} <- parse_ip(rest),
         {:ok, port, rest} <- parse_port(rest) do
      {:ok, %NetAddr{time: time, services: services, ip: ip, port: port}, rest}
    end
  end

  defp parse_time(<<time::32-little, rest::binary>>),
    do: {:ok, time, rest}

  defp parse_time(_binary),
    do: {:error, :bad_time}

  defp parse_services(<<services::64-little, rest::binary>>),
    do: {:ok, services, rest}

  defp parse_services(_binary),
    do: {:error, :bad_services}

  defp parse_ip(<<ip::binary-size(16), rest::binary>>),
    do: {:ok, ip, rest}

  defp parse_ip(_binary),
    do: {:error, :bad_ip}

  defp parse_port(<<port::16-big, rest::binary>>),
    do: {:ok, port, rest}

  defp parse_port(_binary),
    do: {:error, :bad_port}
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.NetAddr do
  def serialize(net_addr),
    do: <<
      serialize_time(net_addr)::binary,
      serialize_services(net_addr)::binary,
      serialize_ip(net_addr)::binary,
      serialize_port(net_addr)::binary
    >>

  defp serialize_time(%{time: time}),
    do: <<time::32-little>>

  defp serialize_services(%{services: services}),
    do: <<services::64-little>>

  defp serialize_ip(%{ip: ip}),
    do: <<:binary.decode_unsigned(ip)::128-big>>

  defp serialize_port(%{port: port}),
    do: <<port::16-big>>
end
