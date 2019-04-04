defmodule AstNinja.AstToStringTest do
  use ExUnit.Case

  alias AstNinja.AstToString

  @code """
  # some comment
  def foo do
    # another comment
    # x
    bar(1,2,3)
    # cc
  end
  """

  test "to_string" do
    AstToString.string_to_quoted(@code)
    |> IO.inspect(label: "xx")
    |> AstToString.to_string()
    |> IO.puts()
  end

  test "string_to_quoted" do
    AstToString.string_to_quoted(@code)
    # |> IO.inspect(label: "x")
  end
end
