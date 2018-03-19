defmodule BitcoinNetwork.Protocol.VarStr do
  defstruct value: nil

  alias BitcoinNetwork.Protocol.VarInt
  alias BitcoinNetwork.Protocol.VarStr

  def parse(binary) do
    with {:ok, %VarInt{value: length}, rest} <- VarInt.parse(binary),
         <<value::binary-size(length), rest::binary>> <- rest do
      {:ok, %VarStr{value: value}, rest}
    end
  end
end

defimpl BitcoinNetwork.Protocol, for: BitcoinNetwork.Protocol.VarStr do
  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.VarInt
  alias BitcoinNetwork.Protocol.VarStr

  def serialize(%VarStr{value: value}) do
    <<Protocol.serialize(%VarInt{value: String.length(value)})::binary, value::binary>>
  end
end
