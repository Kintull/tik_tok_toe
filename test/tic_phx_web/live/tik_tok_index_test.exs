defmodule TicPhxWeb.TikTokIndexTest do
  use TicPhxWeb.ConnCase
  import Phoenix.LiveViewTest

  setup do
    start_supervised!(Room)
    :ok
  end

  test "test no players connected" do
    conn = build_conn()
    {:ok, view, _html} = live(conn, "/tiktok")
    assert render(view) =~ "Waiting for players. Type join."
  end

  test "test one player connected" do
    conn = build_conn()
    {:ok, view, _html} = live(conn, "/tiktok")
    post(conn, "/comment", %{comment: "join", nickname: "a"})
    assert render(view) =~ "Player a is waiting"
    refute render(view) =~ "&#39;s [a] turn"
  end

  test "test two players connected" do
    conn = build_conn()
    {:ok, view, _html} = live(conn, "/tiktok")
    post(conn, "/comment", %{comment: "join", nickname: "a"})
    post(conn, "/comment", %{comment: "join", nickname: "b"})
    assert render(view) =~ "&#39;s turn (a)"
    assert render(view) =~ "a VS b"
    refute render(view) =~ "Player a is waiting for opponent"
  end

  test "test register a move" do
    conn = build_conn()
    {:ok, view, _html} = live(conn, "/tiktok")
    post(conn, "/comment", %{comment: "join", nickname: "a"})
    post(conn, "/comment", %{comment: "join", nickname: "b"})
    post(conn, "/comment", %{comment: "move tl", nickname: "a"})
    assert render(view) =~ ~s(<div class="tile playerX">x</div>)
  end

  test "print top" do
    conn = build_conn()
    assert %{} = Player.increment_wins("a")
    {:ok, view, _html} = live(conn, "/tiktok")
    assert render(view) =~ ~s(a: 1)
  end
end
