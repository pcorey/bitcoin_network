defmodule BitcoinNetwork.Protocol.GetHeaders do
  defstruct version: nil,
            hash_count: nil,
            block_locator_hashes: nil,
            hash_stop: nil

  alias BitcoinNetwork.Protocol.{
    GetHeaders,
    UInt32T,
    Parse,
    VarInt,
    Hash
  }

  import BitcoinNetwork.Protocol.Value, only: [value: 1]

  def command(),
    do: "getheaders"

  def parse(binary, _count) do
    with {:ok, version, rest} <- Parse.parse(UInt32T, binary),
         {:ok, hash_count, rest} <- Parse.parse(VarInt, rest),
         {:ok, block_locator_hashes, rest} <- Parse.parse(Hash, rest, value(hash_count)),
         {:ok, hash_stop, rest} <- Parse.parse(Hash, rest),
         do:
           {:ok,
            %GetHeaders{
              version: version,
              hash_count: hash_count,
              block_locator_hashes: block_locator_hashes,
              hash_stop: hash_stop
            }, rest}
  end
end
