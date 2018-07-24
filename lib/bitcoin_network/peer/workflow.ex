defmodule BitcoinNetwork.Peer.Workflow do
  alias BitcoinNetwork.Peer

  alias BitcoinNetwork.Protocol.{
    Addr,
    GetAddr,
    GetData,
    Inv,
    NotFound,
    Ping,
    Pong,
    Tx,
    Verack,
    Version
  }

  require Logger

  def handle_payload(%Version{}, state) do
    with nonce <- :crypto.strong_rand_bytes(8),
         {:ok, _} <- Peer.send(%Verack{}, state.socket),
         {:ok, _} <- Peer.send(%GetAddr{}, state.socket),
         {:ok, _} <- Peer.send(%Ping{nonce: nonce}, state.socket) do
      {:ok, state}
    else
      {:error, reason} -> {:error, reason, state}
    end
  end

  def handle_payload(%Ping{nonce: nonce}, state) do
    with {:ok, _} <- Peer.send(%Pong{nonce: nonce}, state.socket) do
      {:ok, state}
    else
      {:error, reason} -> {:error, reason, state}
    end
  end

  def handle_payload(%Pong{}, state) do
    :timer.apply_after(
      Application.get_env(:bitcoin_network, :ping_time),
      __MODULE__,
      :ping,
      [state.socket]
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

  def handle_payload(%Inv{count: count, inventory: inventory}, state) do
    Logger.info(
      [
        :reset,
        "Received ",
        :bright,
        :green,
        "#{count}",
        :reset,
        " inventory items."
      ]
      |> IO.ANSI.format()
      |> IO.chardata_to_string()
    )

    Peer.send(%GetData{count: count, inventory: inventory}, state.socket)

    {:ok, state}
  end

  def handle_payload(%NotFound{count: count}, state) do
    Logger.info(
      [
        :reset,
        "Couldn't find ",
        :bright,
        :yellow,
        "#{count}",
        :reset,
        " inventory items."
      ]
      |> IO.ANSI.format()
      |> IO.chardata_to_string()
    )

    {:ok, state}
  end

  def handle_payload(tx = %Tx{}, state) do
    Logger.info(
      [
        :reset,
        "Received ",
        :bright,
        :green,
        "tx",
        :reset,
        "."
      ]
      |> IO.ANSI.format()
      |> IO.chardata_to_string()
    )

    {:ok, state}
  end

  def handle_payload(_payload, state),
    do: {:ok, state}

  def ping(socket) do
    nonce = :crypto.strong_rand_bytes(8)
    Peer.send(%Ping{nonce: nonce}, socket)
  end
end
