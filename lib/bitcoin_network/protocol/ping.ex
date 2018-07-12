defmodule BitcoinNetwork.Protocol.Ping do
  defstruct nonce: 0

  alias BitcoinNetwork.Protocol.Ping

  def parse(binary) do
    with {:ok, nonce, rest} <- parse_nonce(binary) do
      {:ok, %Ping{nonce: nonce}, rest}
    end
  end

  defp parse_nonce(<<nonce::binary-size(8), rest::binary>>),
    do: {:ok, nonce, rest}

  defp parse_nonce(_binary),
    do: {:error, :bad_nonce}
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Ping do
  def serialize(ping) do
    <<
      serialize_nonce(ping)::binary
    >>
  end

  defp serialize_nonce(%{nonce: nonce}),
    do: <<nonce::binary-size(8)>>
end
