defmodule AstNinjaWeb.Channels.ParserChannel do
  use AstNinjaWeb, :channel
  alias AstNinja.Parsers

  def join("parser", _payload, socket) do
    {:ok, socket}
  end

  def handle_in(
        "parse",
        %{"code" => code, "parsers" => parsers, "formatter" => formatter, "options" => options},
        socket
      ) do
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
