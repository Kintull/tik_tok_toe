defmodule Player do
  use Ecto.Schema
  import Ecto.Query
  alias TicPhx.Repo

  schema "players" do
    field :name, :string
    field :games_won, :integer

    timestamps()
  end

  def increment_wins(name) do
    case get_player(name) do
      nil ->
        Repo.insert!(%Player{name: name, games_won: 1})

      %Player{} = player ->
        Ecto.Changeset.change(player, %{games_won: player.games_won + 1})
        |> Repo.update!()
    end
  end

  def get_top_players(limit \\ 10) do
    query =
      from p in Player,
        order_by: [desc: :games_won],
        limit: ^limit,
        select: map(p, [:name, :games_won])

    Repo.all(query)
  end

  defp get_player(name) do
    Repo.get_by(__MODULE__, name: name)
  end
end
