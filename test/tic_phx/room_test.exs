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
    assert {:error, :battle_not_running} = Room.make_turn("a")
  end

  test "make move by current player when running", %{pid: pid} do
    assert :ok = Room.add_player("a")
    assert :ok = Room.add_player("b")
    assert :ok = Room.make_running()
    assert :ok = Room.make_turn("a")
    assert %{current_player: "b"} = :sys.get_state(pid)
  end

  test "make move by not a current player when running" do
    assert :ok = Room.add_player("a")
    assert :ok = Room.add_player("b")
    assert :ok = Room.make_running()
    assert {:error, :not_current_player} = Room.make_turn("b")
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
    assert true == Room.is_current_player?("a")
    assert false == Room.is_current_player?("b")
  end
end
