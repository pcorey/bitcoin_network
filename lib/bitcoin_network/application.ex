defmodule BitcoinNetwork.Application do
  use Application

  def start(_type, _args) do
    {:ok, pid} =
      Supervisor.start_link(
        [peer_supervisor()],
        strategy: :one_for_one
      )

    {:ok, _} =
      BitcoinNetwork.connect_to_node(
        Application.get_env(:bitcoin_network, :ip),
        Application.get_env(:bitcoin_network, :port)
      )

    {:ok, pid}
  end

  defp peer_supervisor,
    do:
      {DynamicSupervisor,
       name: BitcoinNetwork.Peer.Supervisor,
       strategy: :one_for_one,
       max_children: Application.get_env(:bitcoin_network, :max_peers)}
end
