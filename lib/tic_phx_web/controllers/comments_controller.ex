defmodule TicPhxWeb.CommentsController do
  use TicPhxWeb, :controller

  alias Phoenix.PubSub

  def index(conn, %{"comment" => comment, "nickname" => nickname}) do
    #     running_status = Room.is_running()
    process_comment(conn, comment, nickname)
  end

  defp process_comment(conn, "/join", nickname) do
    with {:is_running, false} <- {:is_running, Room.is_running?()},
         {:already_joined, false} <- {:already_joined, already_joined?(nickname)},
         :ok <- Room.add_player(nickname),
         {:is_full, true} <- {:is_full, Room.is_full?()} do

      notify_player_joined(Room.get_players())
      Room.make_running()
      json(conn, %{status: :room_started})

    else
      {:is_full, false} ->
        notify_player_joined(Room.get_players())
        json(conn, %{status: :need_more_players})

      {:is_running, true} ->
        json(conn, %{status: :already_running})

      {:error, :full} ->
        json(conn, %{status: :already_running})

      {:already_joined, true} ->
        json(conn, %{status: :player_already_joined})
    end
  end

  defp process_comment(conn, "/move " <> move, nickname) do
    with {:is_valid_move, true} <- {:is_valid_move, is_valid_move?(move)},
         {:is_running, true} <- {:is_running, Room.is_running?()},
         {:is_current_player, true} <- {:is_current_player, Room.is_current_player?(nickname)} do
      Room.make_turn(nickname)
      notify_player_moved(move)
      json(conn, %{status: :move_successful})
    else
      {:is_valid_move, false} ->
        json(conn, %{status: :invalid_move})

      {:is_running, false} ->
        json(conn, %{status: :battle_not_running})

      {:is_current_player, false} ->
        json(conn, %{status: :not_current_player})
    end
  end

  def is_valid_move?(move) do
    move in [
      "top-l",
      "top-c",
      "top-r",
      "mid-l",
      "mid-c",
      "mid-r",
      "bot-l",
      "bot-c",
      "bot-r"
    ]
  end

  defp notify_player_joined(players_map) do
    players = %{player_x: players_map.player_x, player_o: players_map.player_o}
    PubSub.broadcast(TicPhx.PubSub, "room_updates", {:player_joined, players})
  end

  defp notify_player_moved(move) do
    PubSub.broadcast(TicPhx.PubSub, "room_updates", {:player_moved, move})
  end


  defp already_joined?(nickname) do
    %{player_x: x, player_o: o} = Room.get_players()
    nickname in [x, o]
  end
end
