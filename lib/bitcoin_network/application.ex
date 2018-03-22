defmodule BitcoinNetwork.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {
        DynamicSupervisor,
        strategy: :one_for_one, name: BitcoinNetwork.NodeSupervisor
      },
      {
        Registry,
        keys: :unique, name: BitcoinNetwork.NodeRegistry
      }
    ]

    opts = [
      strategy: :one_for_one,
      name: BitcoinNetwork.Application
    ]

    :observer.start()
    Supervisor.start_link(children, opts)
    BitcoinNetwork.connect(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xFF, 0xFF, 127, 0, 0, 1>>, 18333)
  end
end
