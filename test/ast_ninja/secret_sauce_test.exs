defmodule AstNinja.SecretSauceTest do
  use ExUnit.Case

  alias AstNinja.SecretSauce

  def equal(code) do
    new =
      SecretSauce.string_to_quoted(code)
      |> SecretSauce.to_string()

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
