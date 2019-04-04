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
      |> Code.format_string!()
      |> IO.chardata_to_string()
    end
  after
    Process.delete(:code_formatter_comments)
  end

  defp preserve_comments(line, column, tokens, comment, rest) do
    comments = Process.get(:code_formatter_comments)
    comment = [line: line, column: column, comment: comment]
    Process.put(:code_formatter_comments, [comment | comments])
  end

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

  def remove_parens_from_locals({fun, _, _}, str) do
    if fun in locals_without_parens() do
      {:ok, r} = Regex.compile("^#{fun}\\((.*?)\\)")
      Regex.replace(r, str, "#{fun} \\1")
    else
      str
    end
  end

  def remove_parens_from_locals(_ast, str) do
    str
  end

  @locals_without_parens [
                           # Special forms
                           alias: 1,
                           alias: 2,
                           case: 2,
                           cond: 1,
                           for: :*,
                           import: 1,
                           import: 2,
                           quote: 1,
                           quote: 2,
                           receive: 1,
                           require: 1,
                           require: 2,
                           try: 1,
                           with: :*,

                           # Kernel
                           def: 1,
                           defmodule: 2,
                           def: 2,
                           defp: 1,
                           defp: 2,
                           defguard: 1,
                           defguardp: 1,
                           defmacro: 1,
                           defmacro: 2,
                           defmacrop: 1,
                           defmacrop: 2,
                           defdelegate: 2,
                           defexception: 1,
                           defoverridable: 1,
                           defstruct: 1,
                           destructure: 2,
                           raise: 1,
                           raise: 2,
                           reraise: 2,
                           reraise: 3,
                           if: 2,
                           unless: 2,
                           use: 1,
                           use: 2,

                           # Stdlib,
                           defrecord: 2,
                           defrecord: 3,
                           defrecordp: 2,
                           defrecordp: 3,

                           # Testing
                           all: :*,
                           assert: 1,
                           assert: 2,
                           assert_in_delta: 3,
                           assert_in_delta: 4,
                           assert_raise: 2,
                           assert_raise: 3,
                           assert_receive: 1,
                           assert_receive: 2,
                           assert_receive: 3,
                           assert_received: 1,
                           assert_received: 2,
                           check: 1,
                           check: 2,
                           doctest: 1,
                           doctest: 2,
                           property: 1,
                           property: 2,
                           refute: 1,
                           refute: 2,
                           refute_in_delta: 3,
                           refute_in_delta: 4,
                           refute_receive: 1,
                           refute_receive: 2,
                           refute_receive: 3,
                           refute_received: 1,
                           refute_received: 2,
                           setup: 1,
                           setup: 2,
                           setup_all: 1,
                           setup_all: 2,
                           test: 1,
                           test: 2,

                           # Mix config
                           config: 2,
                           config: 3,
                           import_config: 1
                         ]
                         |> Keyword.keys()

  def locals_without_parens() do
    @locals_without_parens
  end
end
