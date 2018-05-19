defmodule BitcoinNetwork.Node.Supervisor do
  use DynamicSupervisor

  def start_link([]) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
