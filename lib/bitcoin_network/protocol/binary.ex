defmodule BitcoinNetwork.Protocol.Binary do
  def parse(binary, size \\ 1) do
    <<bytes::binary-size(size), rest::binary>> = binary
    {:ok, bytes, rest}
  end

  def new(binary) when is_binary(binary),
    do: binary

  def new(binary, size) when is_binary(binary),
    do:
      size
      |> Kernel.-(byte_size(binary))
      |> Kernel.*(8)
      |> (&<<0::size(&1)>>).()
      |> (&<<binary::binary, &1::binary>>).()
end
