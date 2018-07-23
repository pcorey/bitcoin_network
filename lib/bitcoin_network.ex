defmodule BitcoinNetwork do
  alias BitcoinNetwork.Protocol.NetAddr

  def connect_to_node(%NetAddr{ip: ip, port: port}),
    do: connect_to_node(ip, port)

  def connect_to_node(ip, port),
    do:
      DynamicSupervisor.start_child(BitcoinNetwork.Peer.Supervisor, %{
        id: BitcoinNetwork.Peer.Connection,
        start: {BitcoinNetwork.Peer.Connection, :start_link, [{ip, port}]},
        restart: :transient
      })
end
