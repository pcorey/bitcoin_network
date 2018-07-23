defmodule BitcoinNetwork.Protocol.Pong do
  defstruct nonce: 0

  alias BitcoinNetwork.Protocol.Pong

  def parse(binary) do
    with {:ok, nonce, rest} <- parse_nonce(binary) do
      {:ok, %Pong{nonce: nonce}, rest}
    end
  end

  defp parse_nonce(<<nonce::binary-size(8), rest::binary>>),
    do: {:ok, nonce, rest}

  defp parse_nonce(_binary),
    do: {:error, :bad_nonce}
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Pong do
  def serialize(pong),
    do: <<
      serialize_nonce(pong)::binary
    >>

  defp serialize_nonce(%{nonce: nonce}),
    do: <<nonce::binary-size(8)>>
end
