defmodule TicPhxWeb.CommentsController do
  use TicPhxWeb, :controller

  alias Phoenix.PubSub

  def index(conn, %{"comment" => comment, "nickname" => nickname}) do
    #     running_status = Room.is_running()
    process_comment(conn, comment, nickname)
  end

  defp process_comment(conn, "join", nickname) do
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

  defp process_comment(conn, "move " <> move, nickname) do
    with {:is_valid_move, true} <- {:is_valid_move, is_valid_move?(move)},
         {:is_running, true} <- {:is_running, Room.is_running?()},
         {:is_current_player, {true, player}} <-
           {:is_current_player, Room.is_current_player?(nickname)},
         index <- move_to_position_index(move),
         :ok <- Room.make_turn(player, index) do
      notify_player_moved()
      json(conn, %{status: :move_successful})
    else
      {:ok, {:winner, player}} ->
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

  defp process_comment(conn, _, _) do
    json(conn, %{status: :not_applicable})
  end

  def is_valid_move?(move) do
    move in [
      "top-left",
      "top-center",
      "top-right",
      "middle-left",
      "middle-center",
      "middle-right",
      "bottom-left",
      "bottom-center",
      "bottom-right"
    ]
  end

  def move_to_position_index(move) do
    %{
      "top-left" => 0,
      "top-center" => 1,
      "top-right" => 2,
      "middle-left" => 3,
      "middle-center" => 4,
      "middle-right" => 5,
      "bottom-left" => 6,
      "bottom-center" => 7,
      "bottom-right" => 8
    }
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
