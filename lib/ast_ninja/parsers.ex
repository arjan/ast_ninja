defmodule AstNinja.Parsers do
  @parsers ~w(safe_atom_tokens existing_atom_tokens ast tokens json_ast filter_demo to_string format_algebra int_parser)

  def parsers() do
    @parsers
  end

  def mod(parser) when parser in @parsers do
    Module.concat(__MODULE__, Macro.camelize(parser))
  end

  @defaults [width: 60, limit: :infinity, pretty: true]
  def pretty(data, opts \\ []) do
    inspect(data, Keyword.merge(@defaults, opts))
  end

  @doc """
  Run `fun`, collecting the warnings the Elixir parser emits while it runs.
  """
  def gather_warnings(fun) do
    {result, diagnostics} = Code.with_diagnostics(fun)

    warnings =
      for %{severity: :warning, message: message} = d <- diagnostics do
        %{message: message, file: d[:file], line: line(d[:position])}
      end

    {result, warnings}
  end

  defp line({line, _column}), do: line
  defp line(line), do: line
end
