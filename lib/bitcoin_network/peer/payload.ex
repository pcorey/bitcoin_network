defmodule BitcoinNetwork.Peer.Payload do
  alias BitcoinNetwork.Peer

  alias BitcoinNetwork.Protocol.{
    Addr,
    GetAddr,
    Ping,
    Pong,
    Verack,
    Version
  }

  require Logger

  def handle_payload(%Version{}, state) do
    with :ok <- Peer.send(%Verack{}, state.socket),
         :ok <- Peer.send(%GetAddr{}, state.socket),
         :ok <-
           Peer.send(%Ping{nonce: :crypto.strong_rand_bytes(8)}, state.socket) do
      {:ok, state}
    else
      {:error, reason} -> {:error, reason, state}
    end
  end

  def handle_payload(%Ping{nonce: nonce}, state) do
    with :ok <- Peer.send(%Pong{nonce: nonce}, state.socket) do
      {:ok, state}
    else
      {:error, reason} -> {:error, reason, state}
    end
  end

  def handle_payload(%Pong{}, state) do
    Process.send_after(
      self(),
      :send_ping,
      Application.get_env(:bitcoin_network, :ping_time)
    )

    {:ok, state}
  end

  def handle_payload(%Addr{addr_list: addr_list}, state) do
    Logger.info(
      [
        :reset,
        "Received ",
        :bright,
        :green,
        "#{length(addr_list)}",
        :reset,
        " peers."
      ]
      |> IO.ANSI.format()
      |> IO.chardata_to_string()
    )

    addr_list
    |> Enum.sort_by(& &1.time, &>=/2)
    |> Enum.map(&BitcoinNetwork.connect_to_node/1)

    {:ok, state}
  end

  def handle_payload(_payload, state),
    do: {:ok, state}
end
