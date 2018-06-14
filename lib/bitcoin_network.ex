defmodule BitcoinNetwork do
  alias BitcoinNetwork.Protocol.NetAddr

  def connect_to_node(%NetAddr{ip: ip, port: port}), do: connect_to_node(ip, port)

  def connect_to_node(ip, port) do
    DynamicSupervisor.start_child(BitcoinNetwork.Node.Supervisor, %{
      id: BitcoinNetwork.Node,
      start: {BitcoinNetwork.Node, :start_link, [{ip, port}]},
      restart: :transient
    })
  end
end
