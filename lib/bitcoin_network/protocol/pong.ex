defmodule BitcoinNetwork.Protocol.Pong do
  defstruct nonce: nil

  alias BitcoinNetwork.Protocol.{Pong, UInt64T}

  def command(),
    do: "pong"

  def parse(binary) do
    with {:ok, nonce, rest} <- UInt64T.parse(binary),
         do: {:ok, %Pong{nonce: nonce}, rest}
  end

  def new(nonce),
    do: %Pong{
      nonce: UInt64T.new(nonce)
    }
end
