defmodule AstNinja.Parsers.Ast do
  import AstNinja.Parsers

  def parse(code, options) do
    opts = gather_options(options)

    {result, warnings} =
      gather_warnings(fn ->
        case options["rich_ast"] do
          true ->
            {:ok, AstNinja.SecretSauce.string_to_quoted(code, opts)}

          _ ->
            Code.string_to_quoted(code, opts)
        end
      end)

    metadata = %{atom_count: :erlang.system_info(:atom_count)}

    case result do
      {:ok, ast} ->
        %{code: pretty(ast), warnings: warnings, metadata: metadata}

      {:error, {_, message, x}} ->
        %{error: [message, x], metadata: metadata}
    end
  end

  defp gather_options(options) do
    options
    |> Enum.reduce(
      [],
      fn
        {"existing_atoms", true}, o ->
          [{:existing_atoms_only, true} | o]

        {"safe_atoms", true}, o ->
          [{:existing_atoms_only, :safe} | o]

        {"formatter_metadata", true}, o ->
          [{:formatter_metadata, true} | o]

        _, o ->
          o
      end
    )
  end
end
