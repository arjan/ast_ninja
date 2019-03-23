defmodule AstExplorer.Parsers.ExistingAtomTokens do
  import AstExplorer.Parsers

  def parse(code) do
    opts = [existing_atoms_only: true]

    {result, warnings} =
      gather_warnings(fn -> :elixir.string_to_tokens(to_charlist(code), 0, "main", opts) end)

    metadata = %{atom_count: :erlang.system_info(:atom_count)}

    case result do
      {:ok, data} ->
        %{
          code: pretty(data),
          metadata: metadata,
          warnings: warnings
        }

      {:error, {_, message, x}} ->
        %{error: [message, x], metadata: metadata}

      {:error, _} ->
        %{error: "Tokenize error"}
    end
  end
end
