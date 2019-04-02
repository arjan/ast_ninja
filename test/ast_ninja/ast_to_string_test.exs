defmodule AstNinja.AstToStringTest do
  use ExUnit.Case

  import AstNinja.AstToString

  test "to_string" do
    code = """
    # some comment
    def foo do
      # another comment
      # x
      bar(1,2,3)
      # cc
    end
    """

    IO.puts(code)

    IO.puts(back_to_string(code))
  end
end
