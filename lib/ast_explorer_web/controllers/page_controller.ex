defmodule AstExplorerWeb.PageController do
  use AstExplorerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
