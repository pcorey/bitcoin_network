defmodule BitcoinNetwork.Protocol.VersionTest do
  use ExUnit.Case

  alias BitcoinNetwork.Protocol.{Message, Version, Serialize}

  @moduledoc """
  Tests in this module are based around the `test/fixtures/version.bin` fixture
  which was exported from a wireshark capture. Here's the hext dump for easy
  viewing:

  ```
  00000000  0b 11 09 07 76 65 72 73  69 6f 6e 00 00 00 00 00  |....version.....|
  00000010  66 00 00 00 86 2d 2a c2  7f 11 01 00 0d 00 00 00  |f....-*.........|
  00000020  00 00 00 00 44 ab 15 5b  00 00 00 00 09 00 00 00  |....D..[........|
  00000030  00 00 00 00 00 00 00 00  00 00 00 00 00 00 ff ff  |................|
  00000040  a0 10 e9 d7 47 9d 0d 00  00 00 00 00 00 00 00 00  |....G...........|
  00000050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
  00000060  b0 0d 62 de d7 9a c9 d1  10 2f 53 61 74 6f 73 68  |..b....../Satosh|
  00000070  69 3a 30 2e 31 34 2e 32  2f ea 2e 14 00 01        |i:0.14.2/.....|
  0000007e
  ```
  """

  test "parses a version payload" do
    # version = %Version{
    #   version: 70015,
    #   services: 13,
    #   timestamp: 1_528_146_756,
    #   addr_recv: %VersionNetAddr{
    #     ip: <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 160, 16, 233, 215>>,
    #     port: 18333,
    #     services: 9
    #   },
    #   addr_from: %VersionNetAddr{
    #     ip: <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>,
    #     port: 0,
    #     services: 13
    #   },
    #   nonce: 15_116_783_876_185_394_608,
    #   user_agent: "/Satoshi:0.14.2/",
    #   start_height: 1_322_730,
    #   relay: 1
    # }
    version = %BitcoinNetwork.Protocol.Version{
      addr_from: %BitcoinNetwork.Protocol.VersionNetAddr{
        ip: %BitcoinNetwork.Protocol.IP{value: <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>},
        port: %BitcoinNetwork.Protocol.UInt16T{value: 0},
        services: %BitcoinNetwork.Protocol.UInt64T{value: 13}
      },
      addr_recv: %BitcoinNetwork.Protocol.VersionNetAddr{
        ip: %BitcoinNetwork.Protocol.IP{
          value: <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 160, 16, 233, 215>>
        },
        port: %BitcoinNetwork.Protocol.UInt16T{value: 40263},
        services: %BitcoinNetwork.Protocol.UInt64T{value: 9}
      },
      nonce: %BitcoinNetwork.Protocol.UInt64T{value: 15_116_783_876_185_394_608},
      relay: true,
      services: %BitcoinNetwork.Protocol.UInt64T{
        value: 13
      },
      start_height: %BitcoinNetwork.Protocol.Int32T{value: 1_322_730},
      timestamp: %BitcoinNetwork.Protocol.UInt64T{value: 1_528_146_756},
      user_agent: %BitcoinNetwork.Protocol.VarStr{
        length: %BitcoinNetwork.Protocol.VarInt{
          prefix: <<>>,
          value: %BitcoinNetwork.Protocol.UInt8T{value: 16}
        },
        value: "/Satoshi:0.14.2/"
      },
      version: %BitcoinNetwork.Protocol.Int32T{value: 70015}
    }

    assert {:ok, packet} = File.read("test/fixtures/version.bin")
    assert {:ok, _message, rest} = Message.parse(packet)
    assert {:ok, payload, <<>>} = Version.parse(rest)
    assert payload == version
  end

  test "serializes a version struct" do
    assert {:ok, packet} = File.read("test/fixtures/version.bin")
    assert {:ok, _message, rest} = Message.parse(packet)
    assert {:ok, payload, <<>>} = Version.parse(rest)
    assert packet =~ Serialize.serialize(payload)
  end
end
