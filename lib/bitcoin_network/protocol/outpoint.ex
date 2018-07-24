defmodule BitcoinNetwork.Protocol.Outpoint do
  alias BitcoinNetwork.Protocol.Outpoint

  defstruct hash: nil,
            index: nil

  def parse(binary) do
    with {:ok, hash, rest} <- parse_hash(binary),
         {:ok, index, rest} <- parse_index(rest) do
      {:ok, %Outpoint{hash: hash, index: index}, rest}
    end
  end

  defp parse_hash(<<hash::binary-size(32), rest::binary>>),
    do: {:ok, hash, rest}

  defp parse_hash(_binary),
    do: {:error, :bad_hash}

  defp parse_index(<<index::32-little, rest::binary>>),
    do: {:ok, index, rest}

  defp parse_index(_binary),
    do: {:error, :bad_index}
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Outpoint do
  alias BitcoinNetwork.Protocol

  def serialize(outpoint),
    do: <<
      serialize_hash(outpoint)::binary,
      serialize_index(outpoint)::binary
    >>

  defp serialize_hash(%{hash: hash}),
    do: hash

  defp serialize_index(%{index: index}),
    do: <<index::32-little>>
end
