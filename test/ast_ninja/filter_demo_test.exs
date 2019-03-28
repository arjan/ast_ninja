defmodule AstNinja.FilterDemoTest do
  use ExUnit.Case

  alias AstNinja.FilterDemo, as: Filter

  test "preprocess" do
    # "full text"
    assert {:ok, "~q(foo)"} == Filter.preprocess("text:foo")
    assert {:ok, "~q(foo-bar)"} == Filter.preprocess("text:foo-bar")
    assert {:ok, "~q(foo-bar:aa)"} == Filter.preprocess("text:foo-bar:aa")

    assert {:ok, "~q(foo bar)"} == Filter.preprocess("text:\"foo bar\"")

    # tags
    assert {:ok, "~t(foo)"} == Filter.preprocess("tag:foo")
    assert {:ok, "bla and ~t(foo)"} == Filter.preprocess("bla and tag:foo")
    assert {:ok, "~t(Foo-bar:aa)"} == Filter.preprocess("tag:Foo-bar:aa")
    assert {:ok, "~t(Foo bar)"} == Filter.preprocess("tag:\"Foo bar\"")
  end

  test "good filters" do
    ok = [
      ~s/"new" in tags/,
      ~s/"new" not in tags/,
      ~s/first_name == "arjan"/,
      ~s/first_name =~ "arjan%"/,
      ~s/first_name == "arjan" and "new" in tags/,
      ~s/first_name == "arjan" or "new" not in tags/,
      ~s/text:foo.dd/,
      ~s/text:"hello world" and tag:x/,
      ~s/tag:Foo-bar/
    ]

    for e <- ok do
      assert {:ok, _} = Filter.parse(e)
    end
  end

  test "bad filters" do
    wrong = [
      ~s/a = "1"/,
      ~s/1 + 1 = 2/,
      ~s/"new" + "a"/,
      ~s/foo(1,2,bar)/,
      ~s/first_name = "arjan" + "x"/,
      ~s/asdfsdafsa/,
      ~s/text:"hello world/,
      ~s/Asdfsdafsa/,
      ~s/Arjan fdsfdsfds/
    ]

    for e <- wrong do
      assert {:error, _} = Filter.parse(e)
    end
  end

  test "tag: prefix is preprocessed" do
    {:ok, ast} = Filter.parse("tag:foo")
    {:ok, sql, vars} = Filter.to_sql(ast)
    assert "$1 = ANY(tags)" == sql
    assert ["foo"] == vars

    {:ok, ast} = Filter.parse("tag:a and not tag:b")
    {:ok, sql, vars} = Filter.to_sql(ast)
    assert "$1 = ANY(tags) AND NOT ($2 = ANY(tags))" == sql
    assert ["a", "b"] == vars
  end

  test "text: prefix is preprocessed" do
    {:ok, ast} = Filter.parse("text:foo")
    {:ok, sql, vars} = Filter.to_sql(ast, alias: "u")
    assert "(COALESCE(u.first_name, '') ILIKE $1 OR " <> _ = sql
    assert ["%foo%"] == vars

    #    {:ok, ast} = Filter.parse("text:foo or a == \"a\" or text:bla")
    #    {:ok, sql, vars} = Filter.to_sql(ast)
  end

  test "build sql" do
    assert {:ok, ast} = Filter.parse("first_name == \"Arjan\"")
    assert {:ok, "COALESCE(first_name, '') = $1", ["Arjan"]} = Filter.to_sql(ast)

    assert {:ok, ast} = Filter.parse("first_name != \"Arjan\"")
    assert {:ok, "COALESCE(first_name, '') != $1", ["Arjan"]} = Filter.to_sql(ast)

    {:ok, ast} = Filter.parse("\"foo\" in tags and first_name == \"Arjan\"")
    {:ok, sql, vars} = Filter.to_sql(ast)
    assert ["foo", "Arjan"] == vars
    assert "$1 = ANY(tags) AND COALESCE(first_name, '') = $2" == sql

    assert {:ok, ast} = Filter.parse("city =~ \"Amsterdam%\"")
    assert {:ok, "COALESCE(city, '') LIKE $1", ["Amsterdam%"]} = Filter.to_sql(ast)

    {:ok, ast} = Filter.parse("\"foo\" not in tags")
    {:ok, sql, _vars} = Filter.to_sql(ast)
    assert "NOT ($1 = ANY(tags))" == sql
  end

  test "SQL with table aliases" do
    assert {:ok, ast} = Filter.parse("first_name == \"Arjan\"")
    assert {:ok, "COALESCE(u.first_name, '') = $1", ["Arjan"]} = Filter.to_sql(ast, alias: "u")

    {:ok, ast} = Filter.parse("\"foo\" not in tags")
    {:ok, sql, _vars} = Filter.to_sql(ast, tags_alias: "t")
    assert "NOT ($1 = ANY(t.tags))" == sql
  end

  test "empty AST" do
    {:ok, ast} = Filter.parse("")
    assert {:ok, "true", []} = Filter.to_sql(ast)
  end

  test "var offset" do
    {:ok, ast} = Filter.parse("\"foo\" in tags and first_name == \"Arjan\"")
    {:ok, sql, vars} = Filter.to_sql(ast, var_offset: 3)
    assert ["foo", "Arjan"] == vars
    assert "$4 = ANY(tags) AND COALESCE(first_name, '') = $5" == sql
  end

  test "add AND" do
    {:ok, ast} = Filter.parse("")
    {:ok, sql, _vars} = Filter.to_sql(ast, add_and: true)
    assert " AND (true)" == sql

    {:ok, ast} = Filter.parse("tag:a")
    {:ok, sql, _vars} = Filter.to_sql(ast, add_and: true)
    assert " AND ($1 = ANY(tags))" == sql
  end

  test "sql - JSON fields" do
    assert {:ok, ast} = Filter.parse("status =~ \"web%\"")
    assert {:ok, "COALESCE(user_data->>'status', '') LIKE $1", ["web%"]} = Filter.to_sql(ast)
  end
end
