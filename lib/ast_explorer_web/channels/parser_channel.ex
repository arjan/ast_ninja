defmodule AstExplorerWeb.Channels.ParserChannel do
  use AstExplorerWeb, :channel
  alias AstExplorer.Parsers

  def join("parser", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("parse", %{"code" => code}, socket) do
    response =
      Parsers.parsers()
      |> Enum.map(fn parser ->
        {parser, Parsers.mod(parser).parse(code)}
      end)
      |> Map.new()

    {:reply, {:ok, response}, socket}
  end
end
