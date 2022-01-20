defmodule TicPhx.RoomLogicTest do
  use ExUnit.Case


  test "user action" do
    {:ok, %{0 => "x"} = board} = RoomLogic.user_action("x", 0, board())
    {:error, :space_already_occupied} = RoomLogic.user_action("x", 0, board)
  end

  test "has_winner?" do
    assert {true, "x"} == RoomLogic.has_winner?(board(%{1 => "x", 4 => "x", 7 => "x"}))
    assert {true, "o"} == RoomLogic.has_winner?(board(%{1 => "o", 4 => "o", 7 => "o"}))
    assert false == RoomLogic.has_winner?(board(%{1 => "o", 4 => "x", 7 => "o"}))
  end

  defp board(params \\ %{}) do
    Map.merge(RoomLogic.initial_board(), params)
  end
end
