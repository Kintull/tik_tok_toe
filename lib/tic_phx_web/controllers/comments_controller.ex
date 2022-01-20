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

      notify_player_joined()
      Room.make_running()
      json(conn, %{status: :room_started})

    else
      {:is_full, false} ->
        notify_player_joined()
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
         {:is_current_player, {true, player}} <- {:is_current_player, Room.is_current_player?(nickname)},
         index <- move_to_position_index(move),
         :ok <- Room.make_turn(player, index) do
      notify_player_moved()
      json(conn, %{status: :move_successful})
    else
      {:ok, {:player_won, player}} ->
        notify_player_moved()
        notify_player_won()
        json(conn, %{status: :player_won, player: player})

      {:error, :space_already_occupied} ->
        json(conn, %{status: :space_already_occupied})

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

  def move_to_position_index(move) do
    %{"top-l" => 0, "top-c" => 1, "top-r" => 2,
      "mid-l" => 3, "mid-c" => 4, "mid-r" => 5,
      "bot-l" => 6, "bot-c" => 7, "bot-r" => 8}
    |> Map.get(move)
  end

  defp notify_player_joined() do
    PubSub.broadcast(TicPhx.PubSub, "room_updates", :player_joined)
  end

  defp notify_player_moved() do
    PubSub.broadcast(TicPhx.PubSub, "room_updates", :player_moved)
  end

  defp notify_player_won() do
    PubSub.broadcast(TicPhx.PubSub, "room_updates", :player_won)
  end

  defp already_joined?(nickname) do
    %{player_x: x, player_o: o} = Room.get_players()
    nickname in [x, o]
  end
end
