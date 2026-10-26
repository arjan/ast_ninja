import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ast_ninja, AstNinjaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test-only-0yW1oZpHq4Tq0c8mN3m6bQkqgkU2vH3g6Jd3pWbXc9JmB0fYk1rS2t7uVx",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view, enable_expensive_runtime_checks: true
