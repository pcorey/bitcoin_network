defmodule BitcoinNetwork.Protocol.Ping do
  defstruct nonce: nil

  alias BitcoinNetwork.Protocol.{Ping, UInt64T}

  def command(),
    do: "ping"

  def parse(binary) do
    with {:ok, nonce, rest} <- UInt64T.parse(binary),
         do: {:ok, %Ping{nonce: nonce}, rest}
  end
end
