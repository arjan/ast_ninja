defmodule AstNinja.Parsers.IntParser do
  import AstNinja.Parsers

  def parse(code, _options) do
    with {:ok, tokens, _} <- :int_lexer.string(to_charlist(code)),
         {:ok, ast} <- :int_parser.parse(tokens) do
      %{
        code:
          [
            "Tokens:\n\n",
            pretty(tokens),
            "\n\n",
            "AST:\n\n",
            pretty(ast)
          ]
          |> IO.chardata_to_string()
      }
    else
      {:error, r, _} ->
        %{error: inspect(r)}

      {:error, r} ->
        %{error: inspect(r)}
    end
  end
end
