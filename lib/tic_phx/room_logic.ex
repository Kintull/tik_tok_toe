defmodule RoomLogic do
  @moduledoc """
  Business logic for the Room
  """

  def user_action(mark, index, board) do
    if is_valid_action?(index, board) do
      board = Map.put(board, index, mark)
      {:ok, board}
    else
      {:error, :space_already_occupied}
    end
  end

  def has_winner?(board) do
    win = Enum.filter(winning_conditions(),
      fn [a,b,c] ->
        match?(%{^a => "x", ^b => "x", ^c => "x"}, board)
        || match?(%{^a => "o", ^b => "o", ^c => "o"}, board)
      end)

    case win do
      [[a,_b,_c]] -> {true, board[a]}
      _ -> false
    end
  end

  def is_valid_action?(index, board) do
    board[index] == ""
  end

  defp winning_conditions() do
    [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ]
  end

  def starting_player() do
    :player_x
  end

  def initial_board() do
    %{
      0 => "", 1 => "", 2 => "",
      3 => "", 4 => "", 5 => "",
      6 => "", 7 => "", 8 => ""
    }
  end
end
