defmodule BitcoinNetwork.Protocol.MessageTest do
  use ExUnit.Case

  alias BitcoinNetwork.Protocol.{Message, Pong}

  @moduledoc """
  Tests in this module are designed to verify that the "message" envelope
  correctly parse and serialize.
  """

  test "parses a full pong packet" do
    pong = %Message{
      checksum: <<0x0D, 0x96, 0x88, 0xAC>>,
      command: "pong",
      magic: <<0x0B, 0x11, 0x09, 0x07>>,
      size: 8,
      # <<0xA1, 0x13, 0xBB, 0xE8, 0x52, 0x1, 0x28, 0x44>>
      payload: %Pong{
        nonce: <<161, 19, 187, 232, 82, 1, 40, 68>>
      }
    }

    {:ok, packet} = File.read("test/fixtures/pong.bin")
    {:ok, message, rest} = Message.parse(packet)
    {:ok, payload, <<>>} = Pong.parse(rest)

    assert %{message | payload: payload} == pong
  end

  test "serializes a pong struct into a packet" do
    pong = Message.serialize(%Pong{nonce: <<161, 19, 187, 232, 82, 1, 40, 68>>})

    {:ok, packet} = File.read("test/fixtures/pong.bin")
    assert packet == pong
  end

  test "verifies a checksum" do
    {:ok, packet} = File.read("test/fixtures/pong.bin")
    {:ok, message, rest} = Message.parse(packet)
    {:ok, payload, <<>>} = Pong.parse(rest)
    assert Message.verify_checksum(message, payload)
  end
end
