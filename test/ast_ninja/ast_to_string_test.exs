defmodule AstNinja.AstToStringTest do
  use ExUnit.Case

  alias AstNinja.AstToString

  def equal(code) do
    new =
      AstToString.string_to_quoted(code)
      |> AstToString.to_string()

    assert String.trim(new) == String.trim(code)
  end

  @code """
  # some comment
  def foo do
    # another comment
    # x
    bar(1,2,3)
    # cc
  end
  """

  test "string_to_quoted" do
    # equal("a")
    # equal("1 + 2")

    # equal("""
    # 1 + 2
    # """)

    equal("""
    a

    b
    """)

    equal("""
    a
    # xx
    b
    """)

    equal("""
    a

    b

    c
    d
    #  xx
    e
    """)

    equal("""
    if x do
      # foo
      bar("d")
    end
    """)

    equal("""
    if x, do: bar("d"), else: x
    """)
  end
end
