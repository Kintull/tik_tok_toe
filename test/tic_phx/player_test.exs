defmodule PlayerTest do
  use TicPhx.DataCase

  test "increment wins for new user" do
    assert %{games_won: 1} = Player.increment_wins("a")
  end

  test "increment wins for existing user" do
    Repo.insert!(%Player{name: "a", games_won: 10})
    assert %{games_won: 11} = Player.increment_wins("a")
  end

  test "get top X players" do
    Repo.insert!(%Player{name: "a", games_won: 10})
    Repo.insert!(%Player{name: "b", games_won: 6})
    Repo.insert!(%Player{name: "c", games_won: 1})
    assert [%{games_won: 10, name: "a"}, %{games_won: 6, name: "b"}] = Player.get_top_players(2)
  end
end
