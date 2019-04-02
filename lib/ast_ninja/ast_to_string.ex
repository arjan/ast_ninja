defmodule AstNinja.AstToString do
  @moduledoc """
  Experimentation with interleaving gathered source code comments back into the parsed code.
  """

  @doc """
  Parse the code into an extended AST, putting comments into the AST metadata.
  """
  def string_to_quoted(code) do
  end

  @doc """
  Format code from the AST, including comments
  """
  def back_to_string(code, opts \\ []) do
    file = Keyword.get(opts, :file, "nofile")
    line = Keyword.get(opts, :line, 1)

    tokenizer_options = [
      unescape: false,
      preserve_comments: &preserve_comments/5,
      warn_on_unnecessary_quotes: false
    ]

    charlist = String.to_charlist(code)

    Process.put(:code_formatter_comments, [])

    with {:ok, tokens} <- :elixir.string_to_tokens(charlist, line, file, tokenizer_options),
         {:ok, forms} <- :elixir.tokens_to_quoted(tokens, file, columns: true) do
      Macro.to_string(forms, &format_ast_string/2)
    end
  after
    Process.delete(:code_formatter_comments)
  end

  defp preserve_comments(line, column, tokens, comment, rest) do
    comments = Process.get(:code_formatter_comments)
    comment = [line: line, column: column, comment: comment]
    Process.put(:code_formatter_comments, [comment | comments])
  end

  @locals_without_parens AstNinja.Parsers.ToString.locals_without_parens()

  def format_ast_string({_, meta, _} = ast, str) do
    comments =
      Process.get(:code_formatter_comments)
      |> Enum.filter(&(&1[:line] < meta[:line] && &1[:column] == meta[:column]))
      |> Enum.sort_by(& &1[:line])

    Process.put(:code_formatter_comments, Process.get(:code_formatter_comments) -- comments)

    comments =
      comments
      |> Enum.map(& &1[:comment])
      |> Enum.join("\n")

    case comments do
      "" ->
        remove_parens_from_locals(ast, str)

      _ ->
        comments <> "\n" <> remove_parens_from_locals(ast, str)
    end
  end

  def format_ast_string(_ast, str) do
    str
  end

  def remove_parens_from_locals({fun, _, _}, str) when fun in @locals_without_parens do
    {:ok, r} = Regex.compile("^#{fun}\\((.*?)\\)")
    Regex.replace(r, str, "#{fun} \\1")
  end

  def remove_parens_from_locals(_ast, str) do
    str
  end
end
