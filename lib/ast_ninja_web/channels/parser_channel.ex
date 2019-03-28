defmodule AstNinjaWeb.Channels.ParserChannel do
  use AstNinjaWeb, :channel
  alias AstNinja.Parsers

  def join("parser", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("parse", %{"code" => code, "parsers" => parsers}, socket) do
    response =
      Enum.map(parsers, fn parser ->
        {parser, Parsers.mod(parser).parse(code)}
      end)
      |> Map.new()

    {:reply, {:ok, response}, socket}
  end
end
