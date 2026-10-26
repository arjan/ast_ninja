defmodule AstNinja.MixProject do
  use Mix.Project

  def project do
    [
      app: :ast_ninja,
      version: "0.2.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:leex, :yecc, :phoenix_live_view] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AstNinja.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.8"},
      {:phoenix_html, "~> 4.3"},
      {:phoenix_live_view, "~> 1.2"},
      {:phoenix_live_reload, "~> 1.7", only: :dev},
      {:lazy_html, "~> 0.1.13", only: :test},
      {:esbuild, "~> 0.10.1", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.5.2", runtime: Mix.env() == :dev},
      {:makeup_elixir, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.14"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind ast_ninja", "esbuild ast_ninja"],
      "assets.deploy": [
        "tailwind ast_ninja --minify",
        "esbuild ast_ninja --minify",
        "phx.digest"
      ]
    ]
  end
end
