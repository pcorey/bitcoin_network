defmodule BitcoinNetwork.Protocol.Message do
  defstruct magic: nil,
            command: nil,
            size: nil,
            checksum: nil,
            payload: nil

  alias BitcoinNetwork.Protocol.Message

  alias BitcoinNetwork.Protocol.{
    Addr,
    Binary,
    GetAddr,
    GetData,
    Inv,
    Message,
    NotFound,
    Ping,
    Pong,
    Tx,
    UInt32T,
    Verack,
    Version
  }

  import BitcoinNetwork.Protocol.Serialize, only: [serialize: 1]

  def verify_checksum(message, payload),
    do: Message.Checksum.verify_checksum(message, payload)

  def command(),
    do: "message"

  def parse(binary) do
    with {:ok, magic, rest} <- UInt32T.parse(binary),
         {:ok, command, rest} <- Binary.parse(rest, 12),
         {:ok, size, rest} <- UInt32T.parse(rest),
         {:ok, checksum, rest} <- UInt32T.parse(rest),
         do:
           {:ok,
            %Message{
              magic: magic,
              command: command,
              size: size,
              checksum: checksum
            }, rest}
  end

  def new(message = %module{}, magic \\ 118_034_699) do
    payload = serialize(message)
    checksum = Message.Checksum.checksum(payload)
    command = apply(module, :command, [])

    %Message{
      magic: UInt32T.new(magic),
      command: Binary.new(command, 12),
      size: UInt32T.new(byte_size(payload)),
      checksum: UInt32T.new(checksum),
      payload: Binary.new(payload)
    }
  end

  def parse_payload_module(<<"addr", _::binary>>),
    do: {:ok, Addr}

  def parse_payload_module(<<"getaddr", _::binary>>),
    do: {:ok, GetAddr}

  def parse_payload_module(<<"getdata", _::binary>>),
    do: {:ok, GetData}

  def parse_payload_module(<<"inv", _::binary>>),
    do: {:ok, Inv}

  def parse_payload_module(<<"message", _::binary>>),
    do: {:ok, Message}

  def parse_payload_module(<<"notfound", _::binary>>),
    do: {:ok, NotFound}

  def parse_payload_module(<<"ping", _::binary>>),
    do: {:ok, Ping}

  def parse_payload_module(<<"pong", _::binary>>),
    do: {:ok, Pong}

  # def parse_payload_module(<<"tx", _::binary>>),
  #   do: {:ok, Tx}

  def parse_payload_module(<<"verack", _::binary>>),
    do: {:ok, Verack}

  def parse_payload_module(<<"version", _::binary>>),
    do: {:ok, Version}

  def parse_payload_module(_),
    do: {:error, :unsupported_command}
end
