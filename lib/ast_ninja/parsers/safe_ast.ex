defmodule AstNinja.Parsers.SafeAst do
  import AstNinja.Parsers

  def parse(code) do
    {result, warnings} =
      gather_warnings(fn -> Code.string_to_quoted(code, existing_atoms_only: :safe) end)

    case result do
      {:ok, ast} ->
        %{code: pretty(ast), warnings: warnings}

      {:error, {_line, message, _}} ->
        %{error: message}
    end
  end
end
