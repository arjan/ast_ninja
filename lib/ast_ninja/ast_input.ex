defmodule AstNinja.AstInput do
  @moduledoc """
  Turns user input that is written *as an AST* (e.g. `{:+, [], [1, 2]}`)
  back into source code, so it can be fed to the parsers.

  Only literal terms are evaluated; anything else is rejected before
  `Code.eval_quoted/1` is called.
  """

  defmodule SafeExpression do
    @moduledoc false
    import AstNinja.AstMacro

    defastfilter :parse do
      n when is_integer(n) -> n
      n when is_atom(n) -> n
      n when is_binary(n) -> n
      n when is_list(n) -> n
      {k, _} = n when is_atom(k) -> n
      {:{}, _, _} = n -> n
    end
  end

  @doc """
  Returns `{:ok, code}` with the source code for the AST term in `input`,
  or `{:error, reason}`.
  """
  def to_code(input) do
    with {:parse, {:ok, ast}} <- {:parse, Code.string_to_quoted(input)},
         {:filter, {safe_ast, :ok}} <-
           {:filter, Macro.postwalk(ast, :ok, &SafeExpression.parse/2)},
         {:eval, {term, _bindings}} <- {:eval, Code.eval_quoted(safe_ast)} do
      {:ok, Macro.to_string(term)}
    else
      {:parse, _} -> {:error, "Parse error"}
      {:filter, _} -> {:error, "Disallowed expression"}
    end
  rescue
    _ -> {:error, "AST evaluation error"}
  end
end
