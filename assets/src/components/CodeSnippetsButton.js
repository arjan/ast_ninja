import React from 'react'
import { Popover, Menu, MenuItem, Button } from '@blueprintjs/core'

const FILTER_DEMO = `defmodule AstNinja.FilterDemo.Guards do
  defguard is_var(ast) when is_tuple(ast) and is_atom(elem(ast, 0)) and elem(ast, 2) == nil
end

defmodule AstNinja.FilterDemo do
  @operators ~w(and or == != =~)a

  @user_columns ~w(first_name last_name age email address city country locale)a

  import AstNinja.FilterDemo.Guards

  def preprocess(s) do
    s = String.trim(s)

    s = Regex.replace(~r/(^|[\s])text:\"([^\"].*?)\"([\s]|$)/, s, "\\1~q(\\2)\\3")
    s = Regex.replace(~r/(^|[\s])tag:\"([^\"].*?)\"([\s]|$)/, s, "\\1~t(\\2)\\3")

    # unquoted
    s = Regex.replace(~r/(^|[\s])tag:(.*?)([\s]|$)/, s, "\\1~t(\\2)\\3")
    s = Regex.replace(~r/(^|[\s])text:(.*?)([\s]|$)/, s, "\\1~q(\\2)\\3")

    # quoted
    {:ok, s}
  end

  def parse(s) do
    with {:ok, processed} <- preprocess(s),
         {:ok, parsed} <- Code.string_to_quoted(processed),
         :ok <- assure_toplevel(parsed),
         {filtered, :ok} <- Macro.prewalk(parsed, :ok, &filter_ast_node/2) do
      {:ok, filtered}
    else
      {:error, _} = e -> e
      {_, {:error, _} = e} -> e
    end
  end

  defp assure_toplevel({:__aliases__, _, _}) do
    {:error, "Invalid expression"}
  end

  defp assure_toplevel({_, _, nil}) do
    {:error, "Invalid expression"}
  end

  defp assure_toplevel(_ast) do
    :ok
  end

  defp filter_ast_node(str, :ok) when is_binary(str) do
    {str, :ok}
  end

  defp filter_ast_node({_var, _, nil} = var, :ok) do
    {var, :ok}
  end

  defp filter_ast_node({:in, _, [str, var]} = n, :ok) when is_binary(str) and is_var(var) do
    {n, :ok}
  end

  defp filter_ast_node({:not, _, [{:in, _, [str, var]}]} = n, :ok)
       when is_binary(str) and is_var(var) do
    {n, :ok}
  end

  defp filter_ast_node({:not, _, [_]} = ast, :ok) do
    {ast, :ok}
  end

  defp filter_ast_node({:__block__, _, []} = ast, :ok) do
    {ast, :ok}
  end

  defp filter_ast_node({:__block__, _, [ast]}, :ok) do
    {ast, :ok}
  end

  defp filter_ast_node({op, _, [_var, _val]} = ast, :ok)
       when op in @operators do
    {ast, :ok}
  end

  defp filter_ast_node({:sigil_t, m, [{:<<>>, _, [str]}, []]}, :ok) do
    # ~t(foo) translates to "foo" in tags
    ast = {:in, m, [str, {:tags, m, nil}]}
    {ast, :ok}
  end

  defp filter_ast_node({:sigil_q, m, [{:<<>>, _, [str]}, []]}, :ok) do
    # full text marker
    {{:"$fulltext", m, [str]}, :ok}
  end

  defp filter_ast_node(node, :ok) do
    {node, {:error, "Syntax error"}}
  end

  defp filter_ast_node(node, {:error, _} = e) do
    {node, e}
  end

  ##

  def to_sql(ast, opts  []) do
    {tree, {vars, _opts}} = Macro.postwalk(ast, {[], opts}, &node_to_sql/2)

    sql = tree |> IO.chardata_to_string()
    sql = Regex.replace(~r/s+/, sql, " ")

    sql =
      case opts[:add_and] do
        true -> " AND (#{sql})"
        _ -> sql
      end

    {:ok, sql, Enum.reverse(vars)}
  end

  defp node_to_sql(n, {args, opts}) when is_binary(n) do
    {"$#{length(args) + 1 + (opts[:var_offset] || 0)}", {[n | args], opts}}
  end

  defp node_to_sql({:tags, _, nil}, acc) do
    # non coalescable
    {col_alias(acc, :tags_alias) <> "tags", acc}
  end

  defp node_to_sql({var, _, nil}, acc) when var in @user_columns do
    {["COALESCE(", col_alias(acc) <> to_string(var), ", '')"], acc}
  end

  defp node_to_sql({:{}, [], {}, path}, acc) do
    {path, [last]} = Enum.split(path, Enum.count(path) - 1)
    path_comp = &"'#{to_string(&1)}'"

    node =
      (["user_data" | Enum.map(path, path_comp)]
       |> Enum.intersperse("->")) ++ ["->>", path_comp.(last)]

    {["COALESCE(", col_alias(acc), node, ", '')"], acc}
  end

  defp node_to_sql({var, _, nil}, acc) do
    {["COALESCE(", col_alias(acc), "user_data->>'", to_string(var), "', '')"], acc}
  end

  defp node_to_sql({:"$fulltext", _, [arg]}, {[param | rest], opts} = acc) do
    cols = ["first_name", "last_name", "user_data->>'email'", "user_id"]
    result = cols |> Enum.map(&["COALESCE(", col_alias(acc), &1, ", '') ILIKE ", arg])
    {["(", [result |> Enum.intersperse(" OR ")], ")"], {[like_param(param) | rest], opts}}
  end

  defp node_to_sql({:not, _, [a]}, acc) do
    {["NOT (", a, ")"], acc}
  end

  defp node_to_sql({:in, _, [a, b]}, acc) do
    {[a, " = ANY(", b, ")"], acc}
  end

  defp node_to_sql({:=~, _, [a, b]}, acc) do
    {[a, " LIKE ", b], acc}
  end

  defp node_to_sql({:==, _, [a, b]}, acc) do
    {[a, " = ", b], acc}
  end

  defp node_to_sql({op, _, [a, b]}, acc) when op in @operators do
    op = op |> to_string() |> String.upcase()
    {[a, " ", op, " ", b], acc}
  end

  defp node_to_sql({:__block__, [], []}, acc) do
    {"true", acc}
  end

  defp node_to_sql(nil, acc) do
    {"true", acc}
  end

  defp col_alias({_, opts}, extra_key) do
    case opts[extra_key] || opts[:alias] do
      nil ->
        ""

      str ->
        str <> "."
    end
  end

  defp like_param(p), do: "%#{p}%"
end
`

const SNIPPETS = [
  ['Elixir module', `# this is a demo
defmodule Greeting do
  def hello do
    IO.puts "Hello, world!"
  end
end
`],
  ['Bubblescript', `@intent greeting(match: "hello|hallo|hi|hey|wazzup")

dialog main do
  say "Hi there!"
end

dialog trigger: @greeting do
  say "👋 Hello to you too!"
end
  `],
  ['Filter demo source code', FILTER_DEMO],
  ['Filter expression #1', 'a == "2"'],
  ['Filter expression #2', 'a == "2" and b == "2"'],
]

export const DEFAULT_CODE = SNIPPETS[0][1]

export default class extends React.Component {
  render() {
    const items = SNIPPETS.map(
      ([ title, payload ]) =>
        <MenuItem
          key={title}
          text={title}
          onClick={() => {
            this.props.dispatch({ action: 'code', payload })
            this.props.dispatch({ action: 'parse' })
          }}
        />)

    return (
      <Popover>
        <Button minimal icon="code" rightIcon="chevron-down" />
        <Menu>{items}</Menu>
      </Popover>
    )
  }
}
