defmodule BitcoinNetwork do
  alias BitcoinNetwork.Protocol.NetAddr

  def count_peers() do
    BitcoinNetwork.Node.Supervisor
    |> DynamicSupervisor.count_children()
    |> Map.get(:active)
  end

  def connect_to_node(%NetAddr{ip: ip, port: port}), do: connect_to_node(ip, port)

  def connect_to_node(ip, port) do
    if count_peers() < Application.get_env(:bitcoin_network, :max_peers) do
      DynamicSupervisor.start_child(BitcoinNetwork.Node.Supervisor, %{
        id: BitcoinNetwork.Node,
        start: {BitcoinNetwork.Node, :start_link, [{ip, port}]},
        restart: :transient
      })
    else
      {:error, :max_peers}
    end
  end
end
