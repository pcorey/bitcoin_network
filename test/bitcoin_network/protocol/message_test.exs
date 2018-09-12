defmodule BitcoinNetwork.Protocol.MessageTest do
  use ExUnit.Case

  alias BitcoinNetwork.Protocol.{Message, Pong, Serialize}

  @moduledoc """
  Tests in this module are designed to verify that the "message" envelope
  correctly parse and serialize.
  """

  test "parses a message packet" do
    message =
      4_911_176_849_251_046_305
      |> BitcoinNetwork.Protocol.Pong.new()
      |> Message.new()
      |> Map.put(:payload, nil)

    assert {:ok, packet} = File.read("test/fixtures/pong.bin")
    assert {:ok, parsed, _rest} = Message.parse(packet)

    assert parsed == message
  end

  test "serializes a pong struct into a packet" do
    assert pong =
             4_911_176_849_251_046_305
             |> BitcoinNetwork.Protocol.Pong.new()
             |> Message.new()
             |> Serialize.serialize()

    assert {:ok, packet} = File.read("test/fixtures/pong.bin")
    assert packet == pong
  end

  test "verifies a checksum" do
    assert {:ok, packet} = File.read("test/fixtures/pong.bin")
    assert {:ok, message, rest} = Message.parse(packet)
    assert {:ok, pong, <<>>} = Pong.parse(rest)
    assert Message.verify_checksum(message, pong)
  end
end
