defmodule BitcoinNetwork.Protocol.Block do
  defstruct version: nil,
            prev_block: nil,
            merkle_root: nil,
            timestamp: nil,
            bits: nil,
            nonce: nil,
            tx_count: nil,
            txs: nil

  alias BitcoinNetwork.Protocol.{
    Block,
    UInt32T,
    VarInt,
    Parse,
    Hash
  }

  import BitcoinNetwork.Protocol.Value, only: [value: 1]

  def command(),
    do: "block"

  def parse(binary, _count) do
    with {:ok, version, rest} <- Parse.parse(UInt32T, binary),
         {:ok, prev_block, rest} <- Parse.parse(Hash, rest),
         {:ok, merkle_root, rest} <- Parse.parse(Hash, rest),
         {:ok, timestamp, rest} <- Parse.parse(UInt32T, rest),
         {:ok, bits, rest} <- Parse.parse(UInt32T, rest),
         {:ok, nonce, rest} <- Parse.parse(UInt32T, rest),
         {:ok, tx_count, rest} <- Parse.parse(VarInt, rest),
         {:ok, txs, rest} <- Parse.parse(Tx, rest, value(tx_count)),
         do:
           {:ok,
            %Block{
              version: version,
              prev_block: prev_block,
              merkle_root: merkle_root,
              timestamp: timestamp,
              bits: bits,
              nonce: nonce,
              tx_count: tx_count,
              txs: txs
            }, rest}
  end
end
