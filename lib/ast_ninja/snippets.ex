defmodule AstNinja.Snippets do
  @moduledoc """
  Example inputs for the source editor.
  """

  @filter_demo_path Path.expand("filter_demo.ex", __DIR__)
  @external_resource @filter_demo_path

  @snippets [
    {"Elixir module",
     """
     # this is a demo
     defmodule Greeting do
       def hello do
         IO.puts "Hello, world!"
       end
     end
     """},
    {"Bubblescript",
     """
     @intent greeting(match: "hello|hallo|hi|hey|wazzup")

     dialog main do
       say "Hi there!"
     end

     dialog trigger: @greeting do
       say "👋 Hello to you too!"
     end
     """},
    {"Filter demo source code", File.read!(@filter_demo_path)},
    {"Filter expression #1", ~s(a == "2")},
    {"Filter expression #2", ~s(a == "2" and b == "2")},
    {"Integer expression", "1 + 2 * (3 - 4)"}
  ]

  def all, do: @snippets

  def titles, do: Enum.map(@snippets, &elem(&1, 0))

  def default, do: @snippets |> hd() |> elem(1)

  def get(title), do: List.keyfind(@snippets, title, 0, {nil, nil}) |> elem(1)
end
