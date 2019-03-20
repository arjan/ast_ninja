defmodule AstExplorer.Parsers.Ast do
  import AstExplorer.Parsers

  def parse(code) do
    case Code.string_to_quoted(code) do
      {:ok, ast} ->
        %{code: pretty(ast)}

      {:error, {_line, message, _}} ->
        %{error: message}
    end
  end
end
