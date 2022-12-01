defmodule TicPhx.RoomTest do
  use ExUnit.Case

  setup do
    pid = start_supervised!(Room)
    %{pid: pid}
  end

  test "assign first player", %{pid: pid} do
    assert :ok = Room.add_player("a")

    assert %{player_x: "a", player_o: nil} = :sys.get_state(pid)
  end

  test "assign second player", %{pid: pid} do
    assert :ok = Room.add_player("a")
    assert :ok = Room.add_player("b")

    assert %{player_x: "a", player_o: "b"} = :sys.get_state(pid)
  end

  test "assign third player", %{pid: pid} do
    assert :ok = Room.add_player("a")
    assert :ok = Room.add_player("b")
    assert {:error, :room_is_full} = Room.add_player("c")

    assert %{player_x: "a", player_o: "b"} = :sys.get_state(pid)
  end

  test "assign player when running" do
    assert :ok = Room.add_player("a")
    assert :ok = Room.add_player("b")
    Room.make_running()
    assert {:error, :battle_running} = Room.add_player("a")
  end

  test "reset the room", %{pid: pid} do
    assert :ok = Room.add_player("a")
    assert :ok = Room.reset()

    assert %{player_x: nil} = :sys.get_state(pid)
  end

  test "is_running" do
    assert false == Room.is_running?()
    assert :ok = Room.add_player("a")
    assert :ok = Room.add_player("b")
    assert :ok = Room.make_running()
    assert true == Room.is_running?()
  end

  test "make_move when not running" do
    assert {:error, :battle_not_running} = Room.make_turn("a", 0)
  end

  test "make move by current player when running", %{pid: pid} do
    assert :ok = Room.add_player("a")
    assert :ok = Room.add_player("b")
    assert :ok = Room.make_running()
    assert :ok = Room.make_turn(:player_x, 0)
    assert %{current_player: :player_o} = :sys.get_state(pid)
  end

  test "make winning x move" do
    Room.update_state(%{
      running: true,
      board: %{
        0 => "x",
        1 => "x",
        2 => "",
        3 => "o",
        4 => "o",
        5 => "",
        6 => "",
        7 => "",
        8 => ""
      },
      player_x: "a",
      player_o: "b",
      current_player: :player_x
    })

    assert {:ok, {:winner, :player_x}} = Room.make_turn(:player_x, 2)
  end

  test "make winning o move" do
    Room.update_state(%{
      running: true,
      board: %{
        0 => "x",
        1 => "x",
        2 => "",
        3 => "o",
        4 => "o",
        5 => "",
        6 => "",
        7 => "",
        8 => ""
      },
      player_x: "a",
      player_o: "b",
      current_player: :player_o
    })

    assert {:ok, {:winner, :player_o}} = Room.make_turn(:player_o, 5)
  end

  test "is_full" do
    assert false == Room.is_full?()
    assert :ok = Room.add_player("a")
    assert false == Room.is_full?()
    assert :ok = Room.add_player("b")
    assert true == Room.is_full?()
  end

  test "is_current_player?" do
    assert :ok = Room.add_player("a")
    assert :ok = Room.add_player("b")
    assert :ok = Room.make_running()
    assert {true, :player_x} == Room.is_current_player?("a")
    assert false == Room.is_current_player?("b")
  end

  test "get_board" do
    assert %{0 => "", 8 => ""} = Room.get_board()
  end

  test "get_winner" do
    assert nil == Room.get_winner()
  end
end
