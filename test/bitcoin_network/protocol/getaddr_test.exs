defmodule BitcoinNetwork.Protocol.GetAddrTest do
  use ExUnit.Case

  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.{Message, GetAddr}

  @moduledoc """
  Tests in this module are based around the `test/fixtures/getaddr.bin` fixture
  which was exported from a wireshark capture. Here's the hext dump for easy
  viewing:

  ```
  00000000  0b 11 09 07 67 65 74 61  64 64 72 00 00 00 00 00  |....getaddr.....|
  00000010  00 00 00 00 5d f6 e0 e2                           |....]...|
  00000018
  ```
  """

  test "parses a getaddr payload" do
    getaddr = %GetAddr{}

    assert {:ok, packet} = File.read("test/fixtures/getaddr.bin")
    assert {:ok, _message, rest} = Message.parse(packet)
    assert {:ok, payload, <<>>} = GetAddr.parse(rest)
    assert payload == getaddr
  end

  test "serializes a getaddr struct" do
    assert {:ok, packet} = File.read("test/fixtures/getaddr.bin")
    assert {:ok, _message, rest} = Message.parse(packet)
    assert {:ok, payload, <<>>} = GetAddr.parse(rest)
    assert packet =~ Protocol.serialize(payload)
  end
end
