defmodule AstNinja.Parsers.FormatAlgebra do
  import AstNinja.Parsers

  def parse(code, _options) do
    {result, warnings} = gather_warnings(fn -> Code.Formatter.to_algebra(code) end)

    case result do
      {:ok, ast} ->
        %{code: pretty(ast), warnings: warnings}

      {:error, {_line, message, _}} ->
        %{error: message}
    end
  end
end
