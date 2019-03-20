defmodule AstExplorer.Parsers.Tokens do
  import AstExplorer.Parsers

  def parse(code) do
    case :elixir_tokenizer.tokenize(String.to_charlist(code), 0, []) do
      {:ok, data} ->
        %{code: pretty(data)}

      {:error, {_, _, message, _}, _, _} ->
        %{error: IO.chardata_to_string(message)}

      {:error, _} ->
        %{error: "Tokenize error"}
    end
  end
end
