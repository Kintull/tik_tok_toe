defmodule TicPhxWeb.TikTokIndexTest do
  use TicPhxWeb.ConnCase
  import Phoenix.LiveViewTest

  setup do
    start_supervised!(Room)
    :ok
  end

  test "test one player connected" do
    conn = build_conn()
    {:ok, view, _html} = live(conn, "/tiktok")
    post(conn, "/comment", %{comment: "/join", nickname: "a"})
    assert render(view) =~ "Player a is waiting for opponent"
    refute render(view) =~ "&#39;s [a] turn"
  end

  test "test two players connected" do
    conn = build_conn()
    {:ok, view, _html} = live(conn, "/tiktok")
    post(conn, "/comment", %{comment: "/join", nickname: "a"})
    post(conn, "/comment", %{comment: "/join", nickname: "b"})
    assert render(view) =~ "&#39;s turn (a)"
    assert render(view) =~ "a VS b"
    refute render(view) =~ "Player a is waiting for opponent"
  end

  test "test register a move" do
    conn = build_conn()
    {:ok, view, _html} = live(conn, "/tiktok")
    post(conn, "/comment", %{comment: "/join", nickname: "a"})
    post(conn, "/comment", %{comment: "/join", nickname: "b"})
    post(conn, "/comment", %{comment: "/move top-l", nickname: "b"})
    assert render(view) =~ "move_index is 0"
  end

end
