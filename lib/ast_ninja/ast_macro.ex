defmodule AstNinja.AstMacro do
  defmacro defastfilter(name, do: clauses) when is_list(clauses) do
    [
      clauses
      |> Enum.map(fn
        {:->, _, [[{:when, _, [left, guard]}], right]} ->
          quote do
            def unquote(name)(unquote(left), :ok) when unquote(guard) do
              {unquote(right), :ok}
            end
          end

        {:->, _, [left, right]} ->
          quote do
            def unquote(name)(unquote_splicing(left), :ok) do
              {unquote(right), :ok}
            end
          end
      end),
      quote do
        def unquote(name)(node, :ok) do
          {:error, "Invalid construct: #{Macro.to_string(node)}"}
        end

        def unquote(name)(_node, e) do
          e
        end
      end
    ]
  end
end
