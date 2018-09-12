defmodule BitcoinNetwork.Protocol.VerackTest do
  use ExUnit.Case

  alias BitcoinNetwork.Protocol.{Message, Verack, Serialize}

  @moduledoc """
  Tests in this module are based around the `test/fixtures/verack.bin` fixture
  which was exported from a wireshark capture. Here's the hext dump for easy
  viewing:

  ```
  00000000  0b 11 09 07 76 65 72 61  63 6b 00 00 00 00 00 00  |....verack......|
  00000010  00 00 00 00 5d f6 e0 e2                           |....]...|
  00000018
  ```
  """

  test "parses a verack payload" do
    verack = %Verack{}

    assert {:ok, packet} = File.read("test/fixtures/verack.bin")
    assert {:ok, _message, rest} = Message.parse(packet)
    assert {:ok, payload, <<>>} = Verack.parse(rest)
    assert payload == verack
  end

  test "serializes a verack struct" do
    assert {:ok, packet} = File.read("test/fixtures/verack.bin")
    assert {:ok, _message, rest} = Message.parse(packet)
    assert {:ok, payload, <<>>} = Verack.parse(rest)
    assert packet =~ Serialize.serialize(payload)
  end
end
