defmodule BitcoinNetwork.Peer do
  alias BitcoinNetwork.Protocol.Message

  import BitcoinNetwork.Protocol.Serialize, only: [serialize: 1]

  require Logger

  def send(message, socket) do
    message
    |> Message.new()
    |> serialize()
    |> log()
    |> (&:gen_tcp.send(socket, &1)).()
  end

  defp log(message) do
    [
      :reset,
      :white,
      message
      |> Hexdump.to_string()
    ]
    |> IO.ANSI.format()
    |> IO.chardata_to_string()
    |> IO.puts()

    message
  end
end
