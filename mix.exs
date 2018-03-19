defmodule BitcoinNetwork.MixProject do
  use Mix.Project

  def project do
    [
      app: :bitcoin_network,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BitcoinNetwork.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:short_maps, "~> 0.1.2"}
    ]
  end
end
