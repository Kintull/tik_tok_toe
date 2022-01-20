defmodule TicPhxWeb.TikTokToeLive.Index do
  use TicPhxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(TicPhx.PubSub, "room_updates")

    {:ok, update_assigns(socket)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:player_joined, socket) do
    {:noreply, update_assigns(socket)}
  end

  def handle_info(:player_moved, socket) do
    {:noreply, update_assigns(socket)}
  end

  def handle_info(:player_won, socket) do
    Process.send_after(self(), :reset, 3000)
    {:noreply, update_assigns(socket)}
  end

  def handle_info(:reset, socket) do
    Room.reset()
    {:noreply, update_assigns(socket)}
  end

  defp update_assigns(socket) do
    players = Room.get_players()

    socket
    |> assign(:player_names_map, players)
    |> assign(:board, Room.get_board())
    |> assign(:current_player, Room.get_current_player())
    |> assign(:winner, Room.get_winner())
    |> assign(:player_style_map, player_style_map())
    |> assign(:player_mark_map, player_mark_map())
  end

  defp player_style_map(), do: %{player_x: "playerX", player_o: "playerO"}
  defp player_mark_map(), do: %{player_x: "X", player_o: "O"}
end
