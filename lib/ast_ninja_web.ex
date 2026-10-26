defmodule AstNinjaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, live views and so on.

  This can be used in your application as:

      use AstNinjaWeb, :live_view
      use AstNinjaWeb, :html

  The definitions below will be executed for every live view,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      import Phoenix.Controller, only: [get_csrf_token: 0]

      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      use Gettext, backend: AstNinjaWeb.Gettext

      import Phoenix.HTML
      import AstNinjaWeb.CoreComponents

      alias Phoenix.LiveView.JS
      alias AstNinjaWeb.Layouts

      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: AstNinjaWeb.Endpoint,
        router: AstNinjaWeb.Router,
        statics: AstNinjaWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate live_view/html/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
