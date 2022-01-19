defmodule TicPhxWeb.PageController do
  use TicPhxWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
