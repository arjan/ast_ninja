defmodule AstNinja.AstMacroTest do
  use ExUnit.Case

  test "ast macro" do
    defmodule MyIntegerLanguage do
      import AstNinja.AstMacro

      @operators ~w(+ - * /)a

      defastfilter :parse do
        # constant integer values
        n when is_integer(n) -> n
        # allowed operators
        {op, _, _} = n when op in @operators -> n
        # allow variables
        {var, _, nil} = n when is_atom(var) -> n
      end
    end

    {:ok, ast} = Code.string_to_quoted("1 + 34 * x")
    {^ast, :ok} = Macro.prewalk(ast, :ok, &MyIntegerLanguage.parse/2)

    # IO.inspect(filtered, label: "filtered")
  end
end
