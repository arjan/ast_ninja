defmodule AstExplorer.Parsers do
  @parsers ~w(ast tokens)

  def parsers() do
    @parsers
  end

  def mod(parser) when parser in @parsers do
    Module.concat(__MODULE__, String.capitalize(parser))
  end

  @colors [number: :red, atom: :blue, map: :darkgreen, string: :green]
  def pretty(data) do
    inspect(data, width: 40, pretty: true, syntax_colors: @colors)
  end
end
