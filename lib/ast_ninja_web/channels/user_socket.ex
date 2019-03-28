defmodule AstNinjaWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel("parser", AstNinjaWeb.Channels.ParserChannel)

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
