defmodule BitcoinNetwork.Protocol.Message do
  alias BitcoinNetwork.Protocol.Message

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

  def verify_checksum(message, payload),
    do: Message.Checksum.verify_checksum(message, payload)

  def parse(binary),
    do: Message.Parser.parse(binary)

  def serialize(payload),
    do: Message.Serializer.serialize(payload)

  def parse_payload_module("addr"), do: {:ok, Addr}
  def parse_payload_module("getaddr"), do: {:ok, GetAddr}
  def parse_payload_module("ping"), do: {:ok, Ping}
  def parse_payload_module("pong"), do: {:ok, Pong}
  def parse_payload_module("verack"), do: {:ok, Verack}
  def parse_payload_module("version"), do: {:ok, Version}
  def parse_payload_module(_command), do: {:error, :unsupported_command}
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
