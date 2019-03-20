defmodule AstExplorerWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel("parser", AstExplorerWeb.Channels.ParserChannel)

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
