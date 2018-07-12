defmodule BitcoinNetwork.Protocol.Message.Checksum do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.Message

  def verify_checksum(%Message{size: size, checksum: checksum, payload: payload}) do
    serialized_payload = Protocol.serialize(payload)

    checksum(serialized_payload) == checksum &&
      byte_size(serialized_payload) == size
  end

  def verify_checksum(_),
    do: false

  def checksum(payload) do
    <<checksum::binary-size(4), _::binary>> =
      payload
      |> hash(:sha256)
      |> hash(:sha256)

    checksum
  end

  defp hash(data, algorithm),
    do: :crypto.hash(algorithm, data)
end
