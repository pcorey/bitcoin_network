defmodule BitcoinNetwork.Protocol.Pong do
  defstruct nonce: 0

  alias BitcoinNetwork.Protocol.Pong

  def parse(<<nonce::64-little, rest::binary>>) do
    {:ok, %Pong{nonce: nonce}, rest}
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Pong do
  def serialize(pong) do
    <<pong.nonce::64-little>>
  end
end
