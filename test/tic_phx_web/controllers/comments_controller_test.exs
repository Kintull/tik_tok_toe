defmodule TicPhxWeb.CommentsControllerTest do
  use TicPhxWeb.ConnCase

  setup do
    start_supervised!(Room)
    :ok
  end

  test "POST /comment join", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "join", nickname: "a"})
    assert json_response(conn, 200) == %{"status" => "need_more_players"}
  end

  test "POST /comment join same player", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "join", nickname: "a"})
    assert json_response(conn, 200) == %{"status" => "player_already_joined"}
  end

  test "POST /comment join different players", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "join", nickname: "b"})
    assert json_response(conn, 200) == %{"status" => "room_started"}
  end

  test "POST /comment join 3rd player", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "join", nickname: "b"})
    conn = post(conn, "/comment", %{comment: "join", nickname: "c"})
    assert json_response(conn, 200) == %{"status" => "already_running"}
  end

  test "POST player x wins", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "join", nickname: "b"})
    conn = post(conn, "/comment", %{comment: "move tl", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "move bl", nickname: "b"})
    conn = post(conn, "/comment", %{comment: "move tc", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "move bc", nickname: "b"})
    conn = post(conn, "/comment", %{comment: "move tr", nickname: "a"})

    assert json_response(conn, 200) == %{"status" => "player_won", "player" => "player_x"}
  end

  test "POST player o wins", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "join", nickname: "b"})
    conn = post(conn, "/comment", %{comment: "move tl", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "move bl", nickname: "b"})
    conn = post(conn, "/comment", %{comment: "move tc", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "move bc", nickname: "b"})
    conn = post(conn, "/comment", %{comment: "move mc", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "move br", nickname: "b"})

    assert json_response(conn, 200) == %{"status" => "player_won", "player" => "player_o"}
  end

  test "move to an occupied space", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "join", nickname: "b"})
    conn = post(conn, "/comment", %{comment: "move tl", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "move tl", nickname: "b"})
    assert json_response(conn, 200) == %{"status" => "space_already_occupied"}
  end

  test "move out of turn", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "join", nickname: "b"})
    conn = post(conn, "/comment", %{comment: "move tl", nickname: "b"})
    assert json_response(conn, 200) == %{"status" => "not_current_player"}
  end

  test "move invalid move", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "join", nickname: "b"})
    conn = post(conn, "/comment", %{comment: "move top-k", nickname: "b"})
    assert json_response(conn, 200) == %{"status" => "invalid_move"}
  end

  test "move battle not running", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "move tl", nickname: "b"})
    assert json_response(conn, 200) == %{"status" => "battle_not_running"}
  end
end
