defmodule AstNinja.AstToString do
  @moduledoc """
  Experimentation with interleaving gathered source code comments back into the parsed code.
  """

  @doc """
  Parse the code into an extended AST, putting comments into the AST metadata.
  """
  def string_to_quoted(code, opts \\ []) do
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
         {:ok, forms} <- :elixir.tokens_to_quoted(tokens, file, columns: true),
         {:ok, forms2} <-
           :elixir.tokens_to_quoted(tokens, file, formatter_metadata: true, columns: true) do
      comments = Process.get(:code_formatter_comments)

      comments_lookup =
        comments
        |> Enum.map(&{metadata_key(&1), &1[:comment]})
        |> Map.new()

      {_ast, fmt_metadata_lookup} =
        Macro.prewalk(forms2, [], fn
          {_, m, _} = n, acc -> {n, [{metadata_key(m), m} | acc]}
          n, acc -> {n, acc}
        end)

      fmt_metadata_lookup = Map.new(fmt_metadata_lookup)

      {forms, _remaining_comments} =
        Macro.prewalk(forms, comments, fn
          {a, m, b}, comments ->
            k = metadata_key(m)
            {c, remaining} = Enum.split_with(comments, &(&1[:line] < m[:line]))
            metadata = fmt_metadata_lookup[k] |> Keyword.drop(~w(line column)a)

            {{a,
              Keyword.put(m, :_formatter_metadata, metadata)
              |> Keyword.put(:_comments, c), b}, remaining}

          n, c ->
            {n, c}
        end)

      forms
    end
  after
    Process.delete(:code_formatter_comments)
  end

  defp metadata_key(m) do
    {m[:line], m[:column]}
  end

  defp preserve_comments(line, column, tokens, comment, rest) do
    comments = Process.get(:code_formatter_comments)
    comment = [line: line, column: column, comment: comment]
    Process.put(:code_formatter_comments, [comment | comments])
  end

  @doc """
  Format code from the AST, including comments
  """
  def to_string(rich_ast) do
    Macro.to_string(rich_ast, &format_ast_string/2)
    |> Code.format_string!()
    |> IO.chardata_to_string()
  end

  def format_ast_string({_, meta, _} = ast, str) do
    comments =
      case meta[:_comments] do
        [] ->
          ""

        c ->
          (c |> Enum.reverse() |> Enum.map(& &1[:comment]) |> Enum.join("\n")) <> "\n"
      end

    comments <> remove_parens_from_locals(ast, str)
  end

  def format_ast_string(_ast, str) do
    str
  end

  def remove_parens_from_locals({fun, m, _}, str) when is_atom(fun) do
    fmt = m[:_formatter_metadata]
    IO.inspect(fmt, label: "fmt")

    if fmt[:no_parens] do
      {:ok, r} = Regex.compile("^#{fun}\\((.*?)\\)")
      Regex.replace(r, str, "#{fun} \\1")
    else
      str
    end
  end

  def remove_parens_from_locals(_ast, str) do
    str
  end
end
