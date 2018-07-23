defmodule BitcoinNetwork.Protocol.AddrTest do
  use ExUnit.Case

  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.{Addr, Message, NetAddr}

  @moduledoc """
  Tests in this module are based around the `test/fixtures/addr.bin` fixture
  which was exported from a wireshark capture. Here's the hext dump for easy
  viewing:

  ```
  00000000  0b 11 09 07 61 64 64 72  00 00 00 00 00 00 00 00  |....addr........|
  00000010  1f 00 00 00 a6 b7 58 e6  01 44 ab 15 5b 0d 00 00  |......X..D..[...|
  00000020  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 ff  |................|
  00000030  ff 47 da 42 d2 47 9d                              |.G.B.G.|
  00000037
  ```
  """

  test "parses a addr payload" do
    addr = %Addr{
      count: 1,
      addr_list: [
        %NetAddr{
          ip: <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 71, 218, 66, 210>>,
          port: 18333,
          services: 13,
          time: 1_528_146_756
        }
      ]
    }

    assert {:ok, packet} = File.read("test/fixtures/addr.bin")
    assert {:ok, _message, rest} = Message.parse(packet)
    assert {:ok, payload, <<>>} = Addr.parse(rest)
    assert payload == addr
  end

  test "serializes a addr struct" do
    assert {:ok, packet} = File.read("test/fixtures/addr.bin")
    assert {:ok, _message, rest} = Message.parse(packet)
    assert {:ok, payload, <<>>} = Addr.parse(rest)
    assert packet =~ Protocol.serialize(payload)
  end
end
