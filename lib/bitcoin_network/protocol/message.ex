defmodule BitcoinNetwork.Protocol.Message do
  defstruct magic: nil, command: nil, checksum: nil, payload: nil

  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.{Message, Version}

  def parse(binary) do
    <<magic::32-little, command::binary-size(12), rest::binary>> = binary

    with <<magic::32-little, rest::binary>> <- binary,
         <<command::binary-size(12), rest::binary>> <- rest,
         <<size::32-little, rest::binary>> <- rest,
         <<checksum::32-big, rest::binary>> <- rest,
         <<payload::binary-size(size), rest::binary>> <- rest do
      {:ok,
       %Message{
         magic: magic,
         command: command,
         checksum: checksum,
         payload: parse_payload(command, payload)
       }}
    else
      _ -> nil
    end
  end

  def parse_payload("version", payload) do
    Version.parse(payload)
  end

  def parse_payload(_, payload), do: payload

  def serialize(command, payload \\ <<>>)

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

  def verify_checksum(
        <<_magic::32, _command::96, size::32-little, checksum::32, payload::binary>>
      ) do
    checksum(payload) == checksum && byte_size(payload) == size
  end

  def verify_checksum(_), do: false

  def checksum(payload) do
    <<checksum::32, _::binary>> =
      payload
      |> hash(:sha256)
      |> hash(:sha256)

    checksum
  end

  defp hash(data, algorithm), do: :crypto.hash(algorithm, data)
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.Message do
  alias BitcoinNetwork.Protocol.Message

  def serialize(%Message{command: command, payload: payload}) do
    <<
      Application.get_env(:bitcoin_network, :magic)::binary,
      String.pad_trailing(command, 12, <<0>>)::binary,
      byte_size(payload)::32-little,
      :binary.encode_unsigned(Message.checksum(payload))::binary,
      payload::binary
    >>
  end
end
