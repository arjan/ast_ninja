defmodule AstNinja.Parsers.FormatAlgebra do
  import AstNinja.Parsers

  def parse(code, _options) do
    {result, warnings} =
      gather_warnings(fn ->
        Code.string_to_quoted_with_comments(code,
          literal_encoder: &{:ok, {:__block__, &2, [&1]}},
          token_metadata: true,
          unescape: false
        )
      end)

    case result do
      {:ok, ast, comments} ->
        %{
          code: pretty(Code.quoted_to_algebra(ast, comments: comments, escape: false)),
          warnings: warnings
        }

      {:error, {_line, message, extra}} ->
        %{error: [message, extra]}
    end
  end
end
