defmodule AstNinja.Parsers.Ast do
  import AstNinja.Parsers

  def parse(code) do
    {result, warnings} = gather_warnings(fn -> Code.string_to_quoted(code) end)

    case result do
      {:ok, ast} ->
        %{code: pretty(ast), warnings: warnings}

      {:error, {_line, message, _}} ->
        %{error: message}
    end
  end
end
