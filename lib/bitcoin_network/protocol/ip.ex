defmodule BitcoinNetwork.Protocol.IP do
  defstruct value: nil

  alias BitcoinNetwork.Protocol.{Binary, IP}

  def parse(binary) do
    with {:ok, value, rest} <- Binary.parse(binary, 16),
         do:
           {:ok,
            %IP{
              value: value
            }, rest}
  end

  def new(value),
    do: %IP{
      value: Binary.new(value, 16)
    }
end
