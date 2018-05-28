defmodule BitcoinNetwork.Protocol.MessageTest do
  use ExUnit.Case

  alias BitcoinNetwork.Protocol.{Message, Pong}

  test "parses a full pong packet" do
    pong = %Message{
      checksum: <<0x0D, 0x96, 0x88, 0xAC>>,
      command: "pong",
      magic: <<0x0B, 0x11, 0x09, 0x07>>,
      size: 8,
      parsed_payload: %Pong{
        nonce: 4_911_176_849_251_046_305
      },
      payload: <<0xA1, 0x13, 0xBB, 0xE8, 0x52, 0x1, 0x28, 0x44>>
    }

    {:ok, packet} = File.read("test/fixtures/pong.bin")
    {:ok, message, ""} = Message.parse(packet)

    assert message == pong
  end

  test "serializes a pong struct into a packet" do
    pong =
      "pong"
      |> Message.serialize(%Pong{nonce: 4_911_176_849_251_046_305})

    {:ok, packet} = File.read("test/fixtures/pong.bin")
    assert packet == pong
  end

  test "verifies a checksum" do
    {:ok, packet} = File.read("test/fixtures/pong.bin")
    {:ok, message, ""} = Message.parse(packet)
    assert Message.verify_checksum(message)
  end
end