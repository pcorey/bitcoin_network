defmodule BitcoinNetwork.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [
        %{
          id: BitcoinNetwork.Node,
          start:
            {BitcoinNetwork.Node, :start_link,
             [
               {
                 Application.get_env(:bitcoin_network, :ip),
                 Application.get_env(:bitcoin_network, :port)
               }
             ]}
        }
      ],
      strategy: :one_for_one
    )
  end
end
