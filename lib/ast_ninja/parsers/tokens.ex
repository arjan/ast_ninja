defmodule AstNinja.Parsers.Tokens do
  import AstNinja.Parsers

  def parse(code) do
    {result, warnings} =
      gather_warnings(fn -> :elixir_tokenizer.tokenize(String.to_charlist(code), 0, []) end)

    case result do
      {:ok, data} ->
        %{code: pretty(data), warnings: warnings}

      {:error, {_, _, message, _}, _, _} ->
        %{error: IO.chardata_to_string(message)}

      {:error, _} ->
        %{error: "Tokenize error"}
    end
  end
end
