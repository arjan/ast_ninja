defmodule AstExplorerWeb.Channels.ParserChannelTest do
  use ExUnit.Case

  import AstExplorerWeb.Channels.ParserChannel

  test "json_ast" do
    assert {:ok, _} = pretty_ast("hello")
  end
end
