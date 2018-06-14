defmodule BitcoinNetwork.Application do
  use Application

  def start(_type, _args) do
    {:ok, pid} =
      Supervisor.start_link(
        [
          {DynamicSupervisor,
           name: BitcoinNetwork.Node.Supervisor,
           strategy: :one_for_one,
           max_children: Application.get_env(:bitcoin_network, :max_peers)}
        ],
        strategy: :one_for_one
      )

    {:ok, _} =
      BitcoinNetwork.connect_to_node(
        Application.get_env(:bitcoin_network, :ip),
        Application.get_env(:bitcoin_network, :port)
      )

    {:ok, pid}
  end
end
