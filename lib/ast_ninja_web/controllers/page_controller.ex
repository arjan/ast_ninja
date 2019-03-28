defmodule AstNinjaWeb.PageController do
  use AstNinjaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
