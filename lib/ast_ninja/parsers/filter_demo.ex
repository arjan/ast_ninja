defmodule AstNinja.Parsers.FilterDemo do
  import AstNinja.Parsers

  alias AstNinja.FilterDemo, as: Filter

  def parse(filter, _options) do
    with {:ok, preprocessed} <- Filter.preprocess(filter),
         {:ok, ast} <- Filter.parse(filter),
         {:ok, sql, vars} <- Filter.to_sql(ast) do
      code = [
        "Preprocessed:\n\n",
        pretty(preprocessed),
        "\n\n",
        "AST:\n\n",
        pretty(ast),
        "\n\n",
        "SQL:\n\n",
        pretty(sql, width: 20),
        "\n\n",
        "SQL Vars:\n\n",
        pretty(vars)
      ]

      %{code: IO.chardata_to_string(code)}
    else
      e ->
        IO.inspect(e, label: "e")

        %{error: "Filter parse error"}
    end
  end
end
