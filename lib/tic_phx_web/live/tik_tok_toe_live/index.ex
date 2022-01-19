defmodule TicPhxWeb.TikTokToeLive.Index do
  use TicPhxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(player_x: nil)
      |> assign(player_o: nil)
      |> assign(move: nil)

    if connected?(socket), do: Phoenix.PubSub.subscribe(TicPhx.PubSub, "room_updates")

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:player_joined, players}, socket) do
    socket =
      socket
      |> assign(player_x: players.player_x)
      |> assign(player_o: players.player_o)

    {:noreply, socket}
  end

  def handle_info({:player_moved, move}, socket) do
    socket =
      socket
      |> assign(:move_index, move_to_position_index(move))

    {:noreply, socket}
  end

  defp move_to_position_index(move) do
    %{"top-l" => 0, "top-c" => 1, "top-r" => 2,
      "mid-l" => 3, "mid-c" => 4, "mid-r" => 5,
      "bot-l" => 7, "bot-c" => 8, "bot-r" => 9}

    Map.get()
  end

  #  @impl true
  #  def handle_event("delete", %{"id" => id}, socket) do
  #    tik_tok_toe = Games.get_tik_tok_toe!(id)
  #    {:ok, _} = Games.delete_tik_tok_toe(tik_tok_toe)
  #
  #    {:noreply, assign(socket, :tiks, list_tiks())}
  #  end
end
