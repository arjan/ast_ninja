# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :ast_ninja, AstNinjaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "cTgXQ1EHcVlJS01NIcrSuZjBhNNGv/k5rFCV86/xcuUk9RVsow6h48JXUoWfg3rb",
  render_errors: [view: AstNinjaWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: AstNinja.PubSub

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
