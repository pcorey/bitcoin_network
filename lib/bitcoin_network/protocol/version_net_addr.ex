defmodule BitcoinNetwork.Protocol.VersionNetAddr do
  defstruct services: nil, ip: nil, port: nil

  alias BitcoinNetwork.Protocol.VersionNetAddr

  def parse(binary) do
    with {:ok, services, rest} <- parse_services(binary),
         {:ok, ip, rest} <- parse_ip(rest),
         {:ok, port, rest} <- parse_port(rest) do
      {:ok, %VersionNetAddr{services: services, ip: ip, port: port}, rest}
    end
  end

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

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.VersionNetAddr do
  def serialize(version_net_addr),
    do: <<
      serialize_services(version_net_addr)::binary,
      serialize_ip(version_net_addr)::binary,
      serialize_port(version_net_addr)::binary
    >>

  defp serialize_services(%{services: services}),
    do: <<services::64-little>>

  defp serialize_ip(%{ip: ip}),
    do: <<:binary.decode_unsigned(ip)::128-big>>

  defp serialize_port(%{port: port}),
    do: <<port::16-big>>
end
