defmodule BitcoinNetwork.Protocol.PongTest do
  use ExUnit.Case

  alias BitcoinNetwork.Protocol
  alias BitcoinNetwork.Protocol.{Message, Pong}

  test "parses a pong payload" do
    pong = %Pong{
      nonce: 4_911_176_849_251_046_305
    }

    {:ok, packet} = File.read("test/fixtures/pong.bin")
    {:ok, message, ""} = Message.parse(packet)
    {:ok, parsed, ""} = Pong.parse(message.payload)
    assert parsed == pong
  end

  test "serializes a pong struct" do
    pong = %Pong{
      nonce: 4_911_176_849_251_046_305
    }

    {:ok, packet} = File.read("test/fixtures/pong.bin")
    {:ok, message, ""} = Message.parse(packet)
    serialized = Protocol.serialize(pong)
    assert serialized == message.payload
  end
end
