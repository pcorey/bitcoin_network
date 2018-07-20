defmodule BitcoinNetwork.Protocol.PingTest do
  use ExUnit.Case

  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.{Message, Ping}

  @moduledoc """
  Tests in this module are based around the `test/fixtures/ping.bin` fixture
  which was exported from a wireshark capture. Here's the hext dump for easy
  viewing:

  ```
  00000000  0b 11 09 07 70 69 6e 67  00 00 00 00 00 00 00 00  |....ping........|
  00000010  08 00 00 00 f1 09 9a 62  c4 eb 4f d9 21 bb 20 ea  |.......b..O.!. .|
  00000020
  ```
  """

  test "parses a ping payload" do
    ping = %Ping{
      nonce: <<196, 235, 79, 217, 33, 187, 32, 234>>
    }

    assert {:ok, packet} = File.read("test/fixtures/ping.bin")
    assert {:ok, message, <<>>} = Message.parse(packet)
    assert message.payload == ping
  end

  test "serializes a ping struct" do
    assert {:ok, packet} = File.read("test/fixtures/ping.bin")
    assert {:ok, message, <<>>} = Message.parse(packet)
    assert packet =~ Protocol.serialize(message.payload)
  end
end
