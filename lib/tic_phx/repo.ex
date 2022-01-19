defmodule TicPhx.Repo do
  use Ecto.Repo,
    otp_app: :tic_phx,
    adapter: Ecto.Adapters.Postgres
end
