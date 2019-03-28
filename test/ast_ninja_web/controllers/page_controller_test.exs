defmodule AstNinjaWeb.PageControllerTest do
  use AstNinjaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "AST Ninja"
  end
end
