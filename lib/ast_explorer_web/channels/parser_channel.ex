defmodule AstExplorerWeb.Channels.ParserChannel do
  use AstExplorerWeb, :channel

  def join("parser:ast", _payload, socket) do
    IO.inspect(socket, label: "socket")
    {:ok, socket}
  end

  def handle_in("parse", %{"code" => code}, socket) do
    IO.inspect(code, label: "code")

    response =
      case pretty_ast(code) do
        {:ok, pretty} ->
          %{pretty: pretty}

        {:error, {line, message, _}} ->
          %{error: %{line: line, message: message}}
      end

    {:reply, {:ok, response}, socket}
  end

  @colors [number: :red, atom: :blue, map: :darkgreen, string: :yellow]
  def pretty_ast(code) do
    with {:ok, ast} <- Code.string_to_quoted(code) do
      json_safe = inspect(ast, width: 40, pretty: true, syntax_colors: @colors)
      {:ok, json_safe}
    end
  end
end
