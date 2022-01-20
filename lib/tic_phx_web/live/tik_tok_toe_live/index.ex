defmodule TicPhxWeb.TikTokToeLive.Index do
  use TicPhxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    players = Room.get_players()
    socket =
      socket
      |> assign(:player_x, players.player_x)
      |> assign(:player_o, players.player_o)
      |> assign(:board, Room.get_board())

    if connected?(socket), do: Phoenix.PubSub.subscribe(TicPhx.PubSub, "room_updates")

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:player_joined, socket) do
    players = Room.get_players()

    socket =
      socket
      |> assign(player_x: players.player_x)
      |> assign(player_o: players.player_o)

    IO.inspect("player_joined called")
    {:noreply, socket}
  end

  def handle_info(:player_moved, socket) do
    board = Room.get_board()
    socket =
      socket
      |> assign(:board, board)

    {:noreply, socket}
  end
end
