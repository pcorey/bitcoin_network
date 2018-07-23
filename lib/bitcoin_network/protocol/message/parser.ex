defmodule BitcoinNetwork.Protocol.Message.Parser do
  alias BitcoinNetwork.Protocol.Message

  def parse(binary) do
    with {:ok, magic, rest} <- parse_magic(binary),
         {:ok, command, rest} <- parse_command(rest),
         {:ok, size, rest} <- parse_size(rest),
         {:ok, checksum, rest} <- parse_checksum(rest) do
      {:ok,
       %Message{magic: magic, command: command, size: size, checksum: checksum},
       rest}
    end
  end

  defp parse_magic(<<magic::binary-size(4), rest::binary>>),
    do: {:ok, magic, rest}

  defp parse_magic(_binary),
    do: {:error, :bad_magic}

  defp parse_command(<<command::binary-size(12), rest::binary>>),
    do: {:ok, trim_null_bytes(command), rest}

  defp parse_size(<<size::32-little, rest::binary>>),
    do: {:ok, size, rest}

  defp parse_size(_binary),
    do: {:error, :bad_size}

  defp parse_checksum(<<checksum::binary-size(4), rest::binary>>),
    do: {:ok, checksum, rest}

  defp parse_checksum(_binary),
    do: {:error, :bad_checksum}

  defp trim_null_bytes(string),
    do:
      string
      |> :binary.bin_to_list()
      |> Enum.reject(&(&1 == 0))
      |> :binary.list_to_bin()
end
