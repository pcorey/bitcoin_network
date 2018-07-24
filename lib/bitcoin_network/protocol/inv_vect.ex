defmodule BitcoinNetwork.Protocol.InvVect do
  alias BitcoinNetwork.Protocol.{InvVect}

  defstruct type: nil,
            hash: nil

  def is_error?(%InvVect{type: type}),
    do: type == 0

  def is_msg_tx?(%InvVect{type: type}),
    do: type == 1

  def is_msg_block?(%InvVect{type: type}),
    do: type == 2

  def is_msg_filtered_block?(%InvVect{type: type}),
    do: type == 3

  def is_msg_cmpct_block?(%InvVect{type: type}),
    do: type == 4

  def parse(binary) do
    with {:ok, type, rest} <- parse_type(binary),
         {:ok, hash, rest} <- parse_hash(rest) do
      {:ok, %InvVect{type: type, hash: hash}, rest}
    end
  end

  defp parse_type(<<type::32-little, rest::binary>>),
    do: {:ok, type, rest}

  defp parse_type(_binary),
    do: {:error, :bad_type}

  defp parse_hash(<<hash::binary-size(32), rest::binary>>),
    do: {:ok, hash, rest}

  defp parse_hash(_binary),
    do: {:error, :bad_hash}
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.InvVect do
  def serialize(inv_vect),
    do: <<
      serialize_type(inv_vect)::binary,
      serialize_hash(inv_vect)::binary
    >>

  defp serialize_type(%{type: type}),
    do: <<type::32-little>>

  defp serialize_hash(%{hash: hash}),
    do: <<hash::binary-size(32)>>
end
