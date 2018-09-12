defmodule BitcoinNetwork.Protocol.PingTest do
  use ExUnit.Case

  alias BitcoinNetwork.Protocol.{Message, Ping, Serialize, UInt64T}

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
      nonce: %UInt64T{value: 16_870_689_958_184_086_468}
    }

    assert {:ok, packet} = File.read("test/fixtures/ping.bin")
    assert {:ok, _message, rest} = Message.parse(packet)
    assert {:ok, payload, <<>>} = Ping.parse(rest)
    assert payload == ping
  end

  test "serializes a ping struct" do
    assert {:ok, packet} = File.read("test/fixtures/ping.bin")
    assert {:ok, _message, rest} = Message.parse(packet)
    assert {:ok, payload, <<>>} = Ping.parse(rest)
    assert packet =~ Serialize.serialize(payload)
  end
end
