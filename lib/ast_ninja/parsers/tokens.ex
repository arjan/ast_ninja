defmodule AstNinja.Parsers.Tokens do
  import AstNinja.Parsers

  def parse(code, options) do
    opts = gather_options(options)

    {result, warnings} =
      gather_warnings(fn ->
        :elixir_tokenizer.tokenize(String.to_charlist(code), 0, opts)
      end)

    case result do
      {:ok, _line, _column, _warnings, tokens, _terminators} ->
        %{code: pretty(Enum.reverse(tokens)), warnings: warnings}

      {:error, {_location, message, token}, _rest, _warnings, _tokens} ->
        %{error: [message, token]}
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

        {"check_terminators", true}, o ->
          [{:check_terminators, false} | o]

        _, o ->
          o
      end
    )
  end
end
