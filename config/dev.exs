import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild and tailwind to recompile .js and .css sources.
config :ast_ninja, AstNinjaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "cTgXQ1EHcVlJS01NIcrSuZjBhNNGv/k5rFCV86/xcuUk9RVsow6h48JXUoWfg3rb",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:ast_ninja, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:ast_ninja, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :ast_ninja, AstNinjaWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/ast_ninja_web/(?:live|components)/.*(ex|heex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :default_formatter, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true
