defmodule AstExplorer.Parsers.AtomFreeTokens do
  import AstExplorer.Parsers

  def parse(code) do
    case :atom_free_elixir_tokenizer.tokenize(String.to_charlist(code), 0, 0,
           existing_atoms_only: true
         ) do
      {:ok, data} ->
        %{code: pretty(data), metadata: %{atom_count: :erlang.system_info(:atom_count)}}

      {:error, {_, _, message, _}, _, _} ->
        %{error: IO.chardata_to_string(message)}

      {:error, _} ->
        %{error: "Tokenize error"}
    end
  end
end
