defmodule TicPhxWeb.GameController do
  use TicPhxWeb, :controller

  def reset(conn, _params) do
    Room.reset()
    json(conn, %{status: :reset_successful})
  end
end
