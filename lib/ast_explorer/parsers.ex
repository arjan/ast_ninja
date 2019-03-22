defmodule AstExplorer.Parsers do
  @parsers ~w(atom_free_tokens ast tokens)

  def parsers() do
    @parsers
  end

  def mod(parser) when parser in @parsers do
    Module.concat(__MODULE__, Inflex.camelize(parser))
  end

  @colors [number: :red, atom: :blue, map: :darkgreen, string: :green]
  def pretty(data) do
    inspect(data, width: 40, pretty: true, syntax_colors: @colors)
  end

  def gather_warnings(fun) do
    old = Process.put(:elixir_compiler_pid, self())

    result = fun.()
    warnings = gather_warnings_loop([])

    Process.delete(:elixir_compiler_pid)
    {result, warnings}
  end

  def gather_warnings_loop(acc) do
    receive do
      {:warning, file, line, message} = w ->
        message = IO.chardata_to_string(message)
        gather_warnings_loop([%{message: message, file: file, line: line} | acc])
    after
      0 ->
        acc
    end
  end
end
