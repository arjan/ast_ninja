defmodule AstNinjaWeb.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  See the [Gettext Docs](https://hexdocs.pm/gettext) for detailed usage.
  """
  use Gettext.Backend, otp_app: :ast_ninja
end
