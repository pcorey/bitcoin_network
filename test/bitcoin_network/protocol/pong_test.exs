defmodule BitcoinNetwork.Protocol.PongTest do
  use ExUnit.Case

  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.{Message, Pong}

  @moduledoc """
  Tests in this module are based around the `test/fixtures/pong.bin` fixture
  which was exported from a wireshark capture. Here's the hext dump for easy
  viewing:

  ```
  00000000  0b 11 09 07 70 6f 6e 67  00 00 00 00 00 00 00 00  |....pong........|
  00000010  08 00 00 00 0d 96 88 ac  a1 13 bb e8 52 01 28 44  |............R.(D|
  00000020
  ```
  """

  test "parses a pong payload" do
    pong = %Pong{
      nonce: 4_911_176_849_251_046_305
    }

    assert {:ok, packet} = File.read("test/fixtures/pong.bin")
    assert {:ok, message, <<>>} = Message.parse(packet)
    assert message.parsed_payload == pong
  end

  test "serializes a pong struct" do
    assert {:ok, packet} = File.read("test/fixtures/pong.bin")
    assert {:ok, message, <<>>} = Message.parse(packet)
    assert Protocol.serialize(message.parsed_payload) == message.payload
  end
end
