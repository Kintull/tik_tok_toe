defmodule TicPhx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      TicPhx.Repo,
      # Start the Telemetry supervisor
      TicPhxWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TicPhx.PubSub},
      # Start the Endpoint (http/https)
      TicPhxWeb.Endpoint,
      # Start a worker by calling: TicPhx.Worker.start_link(arg)
      # {TicPhx.Worker, arg}
    ]
    |> maybe_add_room()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TicPhx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TicPhxWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp maybe_add_room(children) do
    if Mix.env() == :test do
      children
    else
      children ++ [Room]
    end

  end
end
