defmodule BitcoinNetwork.Protocol.Array do
  def parse(binary, count, parser),
    do: parse(binary, count, parser, [])

  defp parse(rest, 0, parser, list) do
    {:ok, Enum.reverse(list), rest}
  end

  defp parse(binary, count, parser, list) do
    with {:ok, parsed, rest} <- parser.(binary),
         do: parse(rest, count - 1, parser, [parsed | list])
  end
end
