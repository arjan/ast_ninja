defmodule AstNinja.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    load_custom_elixir_tokenizer()

    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      AstNinjaWeb.Endpoint
      # Starts a worker by calling: AstNinja.Worker.start_link(arg)
      # {AstNinja.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AstNinja.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AstNinjaWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp load_custom_elixir_tokenizer() do
    :code.purge(:elixir_tokenizer)

    [path] =
      :code.get_path()
      |> Enum.map(&to_string/1)
      |> Enum.filter(&String.contains?(&1, "ast_ninja/ebin"))

    {:module, :elixir_tokenizer} = :code.load_abs('#{path}/elixir_tokenizer')
  end
end
