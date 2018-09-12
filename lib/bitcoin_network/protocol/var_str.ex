defmodule BitcoinNetwork.Protocol.VarStr do
  defstruct length: nil,
            value: nil

  alias BitcoinNetwork.Protocol.{
    Binary,
    VarInt,
    VarStr
  }

  import BitcoinNetwork.Protocol.Value, only: [value: 1]

  def parse(binary) do
    with {:ok, length, rest} <- VarInt.parse(binary),
         {:ok, value, rest} <- Binary.parse(rest, value(length)),
         do:
           {:ok,
            %VarStr{
              length: length,
              value: value
            }, rest}
  end

  def new(value),
    do: %VarStr{
      length: VarInt.new(byte_size(value)),
      value: Binary.new(value)
    }
end
