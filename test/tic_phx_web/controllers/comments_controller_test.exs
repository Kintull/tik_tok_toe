defmodule TicPhxWeb.CommentsControllerTest do
  use TicPhxWeb.ConnCase

  setup do
    start_supervised!(Room)
    :ok
  end

  test "POST /comment /join", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "/join", nickname: "a"})
    assert json_response(conn, 200) ==  %{"status" => "need_more_players"}
  end

  test "POST /comment /join same player", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "/join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "/join", nickname: "a"})
    assert json_response(conn, 200) ==  %{"status" => "player_already_joined"}
  end

  test "POST /comment /join different players", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "/join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "/join", nickname: "b"})
    assert json_response(conn, 200) ==  %{"status" => "room_started"}
  end

  test "POST /comment /join 3rd player", %{conn: conn} do
    conn = post(conn, "/comment", %{comment: "/join", nickname: "a"})
    conn = post(conn, "/comment", %{comment: "/join", nickname: "b"})
    conn = post(conn, "/comment", %{comment: "/join", nickname: "c"})
    assert json_response(conn, 200) ==  %{"status" => "already_running"}
  end
end
