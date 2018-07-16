defmodule BitcoinNetwork.Protocol.Message do
  alias BitcoinNetwork.Protocol

  alias BitcoinNetwork.Protocol.{
    Addr,
    GetAddr,
    Message,
    Ping,
    Pong,
    Verack,
    Version
  }

  defstruct magic: nil,
            command: nil,
            size: nil,
            checksum: nil,
            payload: nil

  def parse(binary) do
    with {:ok, magic, rest} <- parse_magic(binary),
         {:ok, command, rest} <- parse_command(rest),
         {:ok, size, rest} <- parse_size(rest),
         {:ok, checksum, rest} <- parse_checksum(rest),
         {:ok, payload, rest} <- parse_payload(rest, command, size) do
      {:ok,
       %Message{
         magic: magic,
         command: command,
         size: size,
         checksum: checksum,
         payload: payload
       }, rest}
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

  defp parse_payload(binary, command, size) do
    IO.puts("#{inspect(command)} #{inspect(parse_payload_module(command))}")

    with <<payload::binary-size(size), _rest::binary>> <- binary,
         {:ok, module} <- parse_payload_module(command) do
      apply(module, :parse, [payload])
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, :bad_payload}
    end
  end

  defp parse_payload_module("addr"), do: {:ok, Addr}
  defp parse_payload_module("getaddr"), do: {:ok, GetAddr}
  defp parse_payload_module("ping"), do: {:ok, Ping}
  defp parse_payload_module("pong"), do: {:ok, Pong}
  defp parse_payload_module("verack"), do: {:ok, Verack}
  defp parse_payload_module("version"), do: {:ok, Version}
  defp parse_payload_module(_command), do: {:error, :unsupported_command}

  defp trim_null_bytes(string) do
    string
    |> :binary.bin_to_list()
    |> Enum.reject(&(&1 == 0))
    |> :binary.list_to_bin()
  end

  def serialize(payload = %Addr{}), do: serialize("addr", payload)
  def serialize(payload = %GetAddr{}), do: serialize("getaddr", payload)
  def serialize(payload = %Ping{}), do: serialize("ping", payload)
  def serialize(payload = %Pong{}), do: serialize("pong", payload)
  def serialize(payload = %Verack{}), do: serialize("verack", payload)
  def serialize(payload = %Version{}), do: serialize("version", payload)

  def serialize(command, payload) when is_binary(payload) do
    Protocol.serialize(%Message{
      command: command,
      payload: payload
    })
  end

  def serialize(command, payload) do
    Protocol.serialize(%Message{
      command: command,
      payload: Protocol.serialize(payload)
    })
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Message do
  alias BitcoinNetwork.Protocol.Message

  def serialize(%Message{command: command, payload: payload}) do
    <<
      serialize_magic()::binary,
      serialize_command(command)::binary,
      serialize_size(payload)::binary,
      serialize_checksum(payload)::binary,
      payload::binary
    >>
  end

  defp serialize_magic(),
    do: Application.get_env(:bitcoin_network, :magic)

  defp serialize_command(command),
    do: String.pad_trailing(command, 12, <<0>>)

  defp serialize_size(payload),
    do: <<byte_size(payload)::32-little>>

  defp serialize_checksum(payload),
    do: Message.Checksum.checksum(payload)
end
