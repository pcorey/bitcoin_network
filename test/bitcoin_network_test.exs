defmodule BitcoinNetworkTest do
  use ExUnit.Case
  doctest BitcoinNetwork

  test "greets the world" do
    assert BitcoinNetwork.hello() == :world
  end
end
