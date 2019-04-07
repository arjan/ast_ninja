defmodule AstNinjaWeb.Channels.ParserChannel do
  use AstNinjaWeb, :channel
  alias AstNinja.Parsers

  defmodule SafeExpression do
    import AstNinja.AstMacro

    defastfilter :parse do
      # constant integer values
      n when is_integer(n) -> n
      n when is_atom(n) -> n
      n when is_binary(n) -> n
      n when is_list(n) -> n
      {k, _} = n when is_atom(k) -> n
      {:{}, _, _} = n -> n
    end
  end

  def join("parser", _payload, socket) do
    {:ok, socket}
  end

  def handle_in(
        "parse",
        %{
          "code" => code,
          "parsers" => parsers,
          "formatter" => formatter,
          "options" => options,
          "code_is_ast" => code_is_ast
        },
        socket
      ) do
    code =
      case code_is_ast do
        false ->
          code

        true ->
          try do
            with {:parse, {:ok, ast}} <- {:parse, Code.string_to_quoted(code)},
                 {:filter, {safe_ast, :ok}} <-
                   {:filter, Macro.postwalk(ast, :ok, &SafeExpression.parse/2)},
                 {:eval, {ast, _bindings}} <- {:eval, Code.eval_quoted(safe_ast)} do
              Macro.to_string(ast)
            else
              {:parse, _} ->
                ~s(\"Parse error\")

              {:filter, e} ->
                IO.inspect(e, label: "e")

                ~s("Disallowed expression")

              {:eval, _} ->
                ~s(\"AST evaluation error\")

              e ->
                IO.inspect(e, label: "e")

                ~s(\"error\")
            end
          catch
            _, _ ->
              ~s(\"error\")
          end
      end

    IO.inspect(code, label: "code")

    response =
      Enum.map(parsers, fn parser ->
        {parser, Parsers.mod(parser).parse(code, options[parser] || %{})}
      end)
      |> Map.new()
      |> opt_format(formatter, code)

    {:reply, {:ok, response}, socket}
  end

  defp opt_format(map, false, _code), do: map

  defp opt_format(map, true, code) do
    try do
      Map.put(map, :formatted, IO.chardata_to_string(Code.format_string!(code)))
    rescue
      SyntaxError ->
        map
    end
  end
end
