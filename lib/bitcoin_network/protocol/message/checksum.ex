defmodule BitcoinNetwork.Protocol.Message.Checksum do
  alias BitcoinNetwork.Protocol.{Message, UInt32T}

  import BitcoinNetwork.Protocol.Serialize, only: [serialize: 1]
  import BitcoinNetwork.Protocol.Value, only: [value: 1]

  def verify_checksum(%Message{size: size, checksum: checksum}, payload) do
    serialized_payload = serialize(payload)

    case checksum(serialized_payload) == checksum && byte_size(serialized_payload) == value(size) do
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

    UInt32T.new(checksum)
  end

  defp hash(data, algorithm),
    do: :crypto.hash(algorithm, data)
end
