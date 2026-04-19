defmodule Framework.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, [name: Swoosh.Finch]},
      FrameworkWeb.Telemetry,
      Framework.Repo,
      {DNSCluster, query: Application.get_env(:framework, :dns_cluster_query) || :ignore},
      PhoenixKit.Supervisor,
      {Phoenix.PubSub, name: Framework.PubSub},
      {Oban, Application.get_env(:framework, Oban)},
      {Cachex, name: :plugin_cache},
      # Start a worker by calling: Framework.Worker.start_link(arg)
      # {Framework.Worker, arg},
      # Start to serve requests, typically the last entry
      FrameworkWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Framework.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FrameworkWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  @build_date Mix.Project.config()[:build_date]
  @build_hash Mix.Project.config()[:build_hash]

  def build_hash, do: [build_hash: @build_hash]
  def build_date, do: [build_date: @build_date]
end
