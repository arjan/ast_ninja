defmodule AstExplorer.Parsers.AstTest do
  use ExUnit.Case

  import AstExplorer.Parsers.JsonAst, only: [ast_to_json: 1]

  test "AST to json" do
    {:ok, ast} = Code.string_to_quoted("a")
    assert %{h: "Variable", l: :a, m: %{line: 1}, r: nil} = ast_to_json(ast)
  end
end
