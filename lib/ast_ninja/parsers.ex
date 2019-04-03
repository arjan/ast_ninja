defmodule AstNinja.Parsers do
  @parsers ~w(safe_atom_tokens existing_atom_tokens ast tokens json_ast filter_demo to_string format_algebra int_parser)

  def parsers() do
    @parsers
  end

  def mod(parser) when parser in @parsers do
    Module.concat(__MODULE__, Inflex.camelize(parser))
  end

  @colors [number: :red, atom: :blue, map: :darkgreen, string: :green]
  @defaults [width: 40, limit: :infinity, pretty: true, syntax_colors: @colors]
  def pretty(data, opts \\ []) do
    inspect(data, Keyword.merge(@defaults, opts))
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
