defmodule BitcoinNetwork.Protocol.Version do
  defstruct version: nil,
            services: nil,
            timestamp: nil,
            addr_recv: nil,
            addr_from: nil,
            nonce: nil,
            user_agent: nil,
            start_height: nil,
            relay: nil

  alias BitcoinNetwork.Protocol.{
    Bool,
    Int32T,
    VersionNetAddr,
    UInt64T,
    VarStr,
    Version
  }

  def command(),
    do: "version"

  def parse(binary) do
    with {:ok, version, rest} <- Int32T.parse(binary),
         {:ok, services, rest} <- UInt64T.parse(rest),
         {:ok, timestamp, rest} <- UInt64T.parse(rest),
         {:ok, addr_recv, rest} <- VersionNetAddr.parse(rest),
         {:ok, addr_from, rest} <- VersionNetAddr.parse(rest),
         {:ok, nonce, rest} <- UInt64T.parse(rest),
         {:ok, user_agent, rest} <- VarStr.parse(rest),
         {:ok, start_height, rest} <- Int32T.parse(rest),
         {:ok, relay, rest} <- Bool.parse(rest),
         do:
           {:ok,
            %Version{
              version: version,
              services: services,
              timestamp: timestamp,
              addr_recv: addr_recv,
              addr_from: addr_from,
              nonce: nonce,
              user_agent: user_agent,
              start_height: start_height,
              relay: relay
            }, rest}
  end

  def new(recv_ip, recv_port, recv_services, user_agent),
    do: %Version{
      version: Int32T.new(Application.get_env(:bitcoin_network, :version)),
      services: UInt64T.new(Application.get_env(:bitcoin_network, :services)),
      user_agent: VarStr.new(user_agent),
      addr_from: VersionNetAddr.new(<<>>, 0, Application.get_env(:bitcoin_network, :services)),
      addr_recv: VersionNetAddr.new(recv_ip, recv_port, recv_services),
      timestamp: UInt64T.new(:os.system_time(:seconds)),
      nonce: UInt64T.new(:binary.decode_unsigned(:crypto.strong_rand_bytes(8))),
      start_height: Int32T.new(1),
      relay: Bool.new(true)
    }
end
