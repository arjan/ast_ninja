defmodule AstExplorerWeb.Channels.ParserChannel do
  use AstExplorerWeb, :channel

  def join("parser:ast", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("parse", %{"code" => code}, socket) do
    response =
      case {parse_ast(code), parse_tokens(code)} do
        {{:ok, ast}, {:ok, tokens}} ->
          %{ast: ast, tokens: tokens}

        {_, {:error, _, _, _}} ->
          %{tokensError: %{line: 0, message: "tokenizer error"}}

        {{:error, {line, message, _}}, {:ok, tokens}} ->
          %{astError: %{line: line, message: message}, tokens: tokens}
      end

    {:reply, {:ok, response}, socket}
  end

  def parse_ast(code) do
    with {:ok, ast} <- Code.string_to_quoted(code) do
      pretty(ast)
    end
  end

  def parse_tokens(code) do
    with {:ok, data} <- :elixir_tokenizer.tokenize(String.to_charlist(code), 0, []) do
      pretty(data)
    end
  end

  @colors [number: :red, atom: :blue, map: :darkgreen, string: :green]
  defp pretty(data) do
    pretty = inspect(data, width: 40, pretty: true, syntax_colors: @colors)
    {:ok, pretty}
  end
end
