defmodule AstNinjaWeb.ErrorHTML do
  @moduledoc """
  Renders error pages, e.g. "Not Found" for a 404.
  """
  use AstNinjaWeb, :html

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
