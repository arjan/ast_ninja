defmodule AstNinja.Parsers.ToString do
  import AstNinja.Parsers

  def parse(code) do
    {result, _warnings} = gather_warnings(fn -> Code.string_to_quoted(code) end)

    case result do
      {:ok, ast} ->
        try do
          formatted =
            ast
            |> Macro.to_string(&remove_parens_from_locals/2)
            |> Code.format_string!()
            |> IO.chardata_to_string()

          %{code: formatted}
        rescue
          e in SyntaxError ->
            %{error: Exception.message(e)}
        end

      {:error, {_line, message, _}} ->
        %{error: message}
    end
  end

  @locals_without_parens [
                           # Special forms
                           alias: 1,
                           alias: 2,
                           case: 2,
                           cond: 1,
                           for: :*,
                           import: 1,
                           import: 2,
                           quote: 1,
                           quote: 2,
                           receive: 1,
                           require: 1,
                           require: 2,
                           try: 1,
                           with: :*,

                           # Kernel
                           def: 1,
                           defmodule: 2,
                           def: 2,
                           defp: 1,
                           defp: 2,
                           defguard: 1,
                           defguardp: 1,
                           defmacro: 1,
                           defmacro: 2,
                           defmacrop: 1,
                           defmacrop: 2,
                           defdelegate: 2,
                           defexception: 1,
                           defoverridable: 1,
                           defstruct: 1,
                           destructure: 2,
                           raise: 1,
                           raise: 2,
                           reraise: 2,
                           reraise: 3,
                           if: 2,
                           unless: 2,
                           use: 1,
                           use: 2,

                           # Stdlib,
                           defrecord: 2,
                           defrecord: 3,
                           defrecordp: 2,
                           defrecordp: 3,

                           # Testing
                           all: :*,
                           assert: 1,
                           assert: 2,
                           assert_in_delta: 3,
                           assert_in_delta: 4,
                           assert_raise: 2,
                           assert_raise: 3,
                           assert_receive: 1,
                           assert_receive: 2,
                           assert_receive: 3,
                           assert_received: 1,
                           assert_received: 2,
                           check: 1,
                           check: 2,
                           doctest: 1,
                           doctest: 2,
                           property: 1,
                           property: 2,
                           refute: 1,
                           refute: 2,
                           refute_in_delta: 3,
                           refute_in_delta: 4,
                           refute_receive: 1,
                           refute_receive: 2,
                           refute_receive: 3,
                           refute_received: 1,
                           refute_received: 2,
                           setup: 1,
                           setup: 2,
                           setup_all: 1,
                           setup_all: 2,
                           test: 1,
                           test: 2,

                           # Mix config
                           config: 2,
                           config: 3,
                           import_config: 1
                         ]
                         |> Keyword.keys()

  def remove_parens_from_locals({fun, _, _}, str) when fun in @locals_without_parens do
    {:ok, r} = Regex.compile("^#{fun}\\((.*?)\\)(,?) do")
    Regex.replace(r, str, "#{fun} \\1 do")
  end

  def remove_parens_from_locals(_ast, str) do
    str
  end
end
