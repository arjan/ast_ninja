defmodule AstNinja.Parsers.JsonAst do
  import AstNinja.Parsers

  def parse(code, _options) do
    {result, warnings} = gather_warnings(fn -> Code.string_to_quoted(code) end)

    case result do
      {:ok, ast} ->
        ast = ast_to_json(ast)
        IO.inspect(ast, label: "ast")
        %{ast: ast, warnings: warnings}

      {:error, {_line, message, _}} ->
        %{error: message}
    end
  end

  def ast_to_json(ast) do
    Macro.postwalk(
      ast,
      fn
        {l, m, r} = ast -> %{l: l, m: Map.new(m), r: r, h: help(ast)}
        {tag, value} when tag in ~w(do else after rescue)a -> %{tag => value}
        value -> value
      end
    )
  end

  defp help({:__block__, _, l}) when is_list(l), do: "Block"
  defp help({:{}, _, l}) when is_list(l), do: "Tuple"
  defp help({:%{}, _, l}) when is_list(l), do: "Map"
  defp help({var, _, nil}) when is_atom(var), do: "Variable"
  defp help({var, _, l}) when is_atom(var) and is_list(l), do: "Function call"
  defp help(_), do: nil
end
