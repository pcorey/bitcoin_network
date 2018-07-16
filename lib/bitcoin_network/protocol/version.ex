defmodule BitcoinNetwork.Protocol.Version do
  alias BitcoinNetwork.Protocol.{VersionNetAddr, VarStr, Version}

  defstruct version: nil,
            services: nil,
            timestamp: nil,
            recv_ip: nil,
            recv_port: nil,
            recv_services: nil,
            from_ip: nil,
            from_port: nil,
            from_services: nil,
            nonce: nil,
            user_agent: nil,
            start_height: nil,
            relay: 1

  def parse(binary) do
    with {:ok, version, rest} <- parse_version(binary),
         {:ok, services, rest} <- parse_services(rest),
         {:ok, timestamp, rest} <- parse_timestamp(rest),
         {:ok, recv_ip, recv_port, recv_services, rest} <- parse_net_addr(rest),
         {:ok, from_ip, from_port, from_services, rest} <- parse_net_addr(rest),
         {:ok, nonce, rest} <- parse_nonce(rest),
         {:ok, user_agent, rest} <- parse_user_agent(rest),
         {:ok, start_height, rest} <- parse_start_height(rest),
         {:ok, relay, rest} <- parse_relay(rest) do
      {:ok,
       %Version{
         version: version,
         services: services,
         timestamp: timestamp,
         recv_ip: recv_ip,
         recv_port: recv_port,
         recv_services: recv_services,
         from_ip: from_ip,
         from_port: from_port,
         from_services: from_services,
         nonce: nonce,
         user_agent: user_agent,
         start_height: start_height,
         relay: relay
       }, rest}
    end
  end

  defp parse_version(<<version::32-little, rest::binary>>),
    do: {:ok, version, rest}

  defp parse_version(_binary),
    do: {:error, :bad_version}

  defp parse_services(<<services::64-little, rest::binary>>),
    do: {:ok, services, rest}

  defp parse_services(_binary),
    do: {:error, :bad_binary}

  defp parse_timestamp(<<timestamp::64-little, rest::binary>>),
    do: {:ok, timestamp, rest}

  defp parse_timestamp(_binary),
    do: {:error, :bad_binary}

  defp parse_net_addr(binary) do
    with {:ok, %VersionNetAddr{ip: ip, port: port, services: services}, rest} <-
           VersionNetAddr.parse(binary) do
      {:ok, ip, port, services, rest}
    end
  end

  defp parse_nonce(<<nonce::64-little, rest::binary>>),
    do: {:ok, nonce, rest}

  defp parse_nonce(_binary),
    do: {:error, :bad_nonce}

  defp parse_user_agent(binary) do
    with {:ok, %VarStr{value: user_agent}, rest} <- VarStr.parse(binary) do
      {:ok, user_agent, rest}
    end
  end

  defp parse_start_height(<<start_height::32-little, rest::binary>>),
    do: {:ok, start_height, rest}

  defp parse_start_height(_binary),
    do: {:error, :bad_start_height}

  defp parse_relay(<<relay::8-little, rest::binary>>),
    do: {:ok, relay, rest}

  defp parse_relay(_binary),
    do: {:error, :bad_relay}
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Version do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.{VersionNetAddr, VarStr}

  def serialize(version) do
    <<
      serialize_version(version)::binary,
      serialize_services(version)::binary,
      serialize_timestamp(version)::binary,
      serialize_recv_net_addr(version)::binary,
      serialize_from_net_addr(version)::binary,
      serialize_nonce(version)::binary,
      serialize_user_agent(version)::binary,
      serialize_start_height(version)::binary,
      serialize_relay(version)::binary
    >>
  end

  defp serialize_version(%{version: version}),
    do: <<version::32-little>>

  defp serialize_services(%{services: services}),
    do: <<services::64-little>>

  defp serialize_timestamp(%{timestamp: timestamp}),
    do: <<timestamp::64-little>>

  defp serialize_recv_net_addr(%{
         recv_services: services,
         recv_ip: ip,
         recv_port: port
       }),
       do: serialize_net_addr(services, ip, port)

  defp serialize_from_net_addr(%{
         from_services: services,
         from_ip: ip,
         from_port: port
       }),
       do: serialize_net_addr(services, ip, port)

  defp serialize_net_addr(services, ip, port),
    do:
      Protocol.serialize(%VersionNetAddr{
        services: services,
        ip: ip,
        port: port
      })

  defp serialize_nonce(%{nonce: nonce}),
    do: <<nonce::64-little>>

  defp serialize_user_agent(%{user_agent: user_agent}),
    do: Protocol.serialize(%VarStr{value: user_agent})

  defp serialize_start_height(%{start_height: start_height}),
    do: <<start_height::32-little>>

  defp serialize_relay(%{relay: relay}),
    do: <<relay::8-little>>
end
