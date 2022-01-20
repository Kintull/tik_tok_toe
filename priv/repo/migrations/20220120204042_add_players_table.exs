defmodule TicPhx.Repo.Migrations.AddPlayersTable do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :name, :string
      add :games_won, :integer
      timestamps()
    end
  end
end
