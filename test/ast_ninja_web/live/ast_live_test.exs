defmodule AstNinjaWeb.AstLiveTest do
  use AstNinjaWeb.ConnCase, async: true

  test "parses edited code in the active panel", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> form("#panel-form", panel: "tokens") |> render_change()
    assert_patch(view, ~p"/?panel=tokens")

    view |> form("#editor-form", code: "unique_var_name + 1") |> render_change()

    assert render(view) =~ "unique_var_name"
    refute has_element?(view, ".callout-error")
  end

  test "shows a parse error and keeps the last good output", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    view |> form("#editor-form", code: "kept_output") |> render_change()
    view |> form("#editor-form", code: "kept_output(") |> render_change()

    assert has_element?(view, ".callout-error")
    assert render(view) =~ "kept_output"
  end
end
