defmodule BitcoinNetwork.Protocol.Version do
  defstruct version: nil,
            services: nil,
            timestamp: nil,
            recv_ip: nil,
            recv_port: nil,
            from_ip: nil,
            from_port: nil,
            nonce: nil,
            user_agent: nil,
            start_height: nil

  alias BitcoinNetwork.Protocol.{VersionNetAddr, VarStr, Version}
  import ShortMaps

  def parse(binary) do
    with <<version::32-little, rest::binary>> <- binary,
         <<services::64-little, rest::binary>> <- rest,
         <<timestamp::64-little, rest::binary>> <- rest,
         {:ok, %VersionNetAddr{ip: recv_ip, port: recv_port}, rest} <- VersionNetAddr.parse(rest),
         {:ok, %VersionNetAddr{ip: from_ip, port: from_port}, rest} <- VersionNetAddr.parse(rest),
         <<nonce::64-little, rest::binary>> <- rest,
         {:ok, %VarStr{value: user_agent}, rest} <- VarStr.parse(rest),
         <<start_height::32-little, rest::binary>> <- rest do
      {:ok, ~m(
         %Version
         version
         services
         timestamp
         recv_ip
         recv_port
         from_ip
         from_port
         nonce
         user_agent
         start_height
       )a, rest}
    end
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Version do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.{VersionNetAddr, VarStr, Version}

  def serialize(version) do
    <<
      version.version::32-little,
      version.services::64-little,
      version.timestamp::64-little,
      Protocol.serialize(%VersionNetAddr{
        services: version.services,
        ip: version.recv_ip,
        port: version.recv_port
      })::binary,
      Protocol.serialize(%VersionNetAddr{
        services: version.services,
        ip: version.from_ip,
        port: version.from_port
      })::binary,
      version.nonce::64-little,
      Protocol.serialize(%VarStr{value: version.user_agent})::binary,
      version.start_height::32-little
    >>
  end
end
