defmodule AstNinjaWeb.Router do
  use AstNinjaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AstNinjaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", AstNinjaWeb do
    pipe_through :browser

    live "/", AstLive
  end
end
