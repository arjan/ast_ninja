defmodule AstNinja.Parsers.ToString do
  import AstNinja.Parsers

  defp ast_opts("formatter_metadata"), do: [formatter_metadata: true]
  defp ast_opts(_), do: []

  def parse(code, options) do
    {result, warnings} =
      gather_warnings(fn -> Code.string_to_quoted(code, ast_opts(options["Method"])) end)

    case result do
      {:ok, ast} ->
        try do
          formatted = format_ast(options["Method"], ast, code)
          %{code: formatted, warnings: warnings, equal: code == formatted}
        rescue
          e in SyntaxError ->
            %{error: Exception.message(e)}
        end

      {:error, {_line, message, e}} ->
        %{error: [message, e]}
    end
  end

  defp format_ast(nil, ast, _code) do
    ast
    |> Macro.to_string()
  end

  defp format_ast("naive", ast, _code) do
    ast
    |> Macro.to_string()
  end

  defp format_ast("naive + formatter", ast, _code) do
    ast
    |> Macro.to_string()
    |> Code.format_string!()
    |> IO.chardata_to_string()
  end

  defp format_ast("formatter_metadata", ast, _code) do
    ast
    |> Macro.to_string()
    |> Code.format_string!()
    |> IO.chardata_to_string()
  end

  defp format_ast("secret_sauce", _ast, code) do
    AstNinja.AstToString.back_to_string(code)
  end
end
