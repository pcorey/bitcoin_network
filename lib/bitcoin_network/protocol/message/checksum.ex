defmodule BitcoinNetwork.Protocol.Message.Checksum do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.Message

  def verify_checksum(%Message{size: size, checksum: checksum}, payload) do
    serialized_payload = Protocol.serialize(payload)

    case checksum(serialized_payload) == checksum &&
           byte_size(serialized_payload) == size do
      true -> {:ok, checksum}
      false -> {:error, :bad_checksum}
    end
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
