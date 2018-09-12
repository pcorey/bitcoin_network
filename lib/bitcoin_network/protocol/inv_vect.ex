defmodule BitcoinNetwork.Protocol.InvVect do
  defstruct type: nil,
            hash: nil

  alias BitcoinNetwork.Protocol.{
    Binary,
    InvVect,
    UInt32T
  }

  def parse(binary) do
    with {:ok, type, rest} <- UInt32T.parse(binary),
         {:ok, hash, rest} <- Binary.parse(rest, 32),
         do:
           {:ok,
            %InvVect{
              type: type,
              hash: hash
            }, rest}
  end
end
