defmodule BitcoinNetwork do
  @moduledoc """
  Documentation for BitcoinNetwork.
  """

  def connect(ip, port) do
    DynamicSupervisor.start_child(
      BitcoinNetwork.NodeSupervisor,
      {BitcoinNetwork.Node, {ip, port}}
    )
  end
end
