defmodule Framework.MixProject do
  use Mix.Project

  def project do
    [
      app: :framework,
      description: "A ERP for Printable Services",
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view, :phoenix_kit_css_sources] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader],
      build_date: DateTime.utc_now(),
      build_hash: __MODULE__.get_hash()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Framework.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
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
      {:igniter, "~> 0.7"},
      {:finch, "~> 0.18"},
      {:phoenix, "~> 1.8.3"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.13"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.16"},
      {:req, "~> 0.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.2.0"},
      {:bandit, "~> 1.5"},
      {:remote_ip, "~> 1.1"},
      {:cachex, "~> 4.0"},
      {:phoenix_kit,
       github: "BeamLabUS/phoenix_kit", branch: "dashboard-widgets", override: true},
      # {:phoenix_kit, path: "../phoenix_kit", override: true},
      {:phoenix_kit_billing, github: "BeamLabUS/phoenix_kit_billing", override: true},
      #  {:phoenix_kit_billing, path: "../phoenix_kit_billing", override: true},
      {:phoenix_kit_legal, github: "BeamLabEU/phoenix_kit_legal"},
      {:phoenix_kit_sync, github: "BeamLabEU/phoenix_kit_sync"},
      {:phoenix_kit_catalogue, github: "BeamLabEU/phoenix_kit_catalogue"},
      {:phoenix_kit_entities, github: "BeamLabEU/phoenix_kit_entities"},
      {:phoenix_kit_emails, github: "BeamLabEU/phoenix_kit_emails"},
      {:phoenix_kit_newsletters, github: "BeamLabEU/phoenix_kit_newsletters"},
      {:phoenix_kit_ecommerce, github: "BeamLabEU/phoenix_kit_ecommerce"},
      {:phoenix_kit_locations, github: "BeamLabEU/phoenix_kit_locations"},
      {:gridstack, github: "gridstack/gridstack.js", app: false, compile: false},
      {:resend, "~> 0.4.0"},
      {:ash, "~> 3.24"},
      {:ash_postgres, "~> 2.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ash.setup", "assets.setup", "assets.build", "run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ash.setup --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind framework", "esbuild framework"],
      "assets.deploy": [
        "cmd --cd assets npm ci",
        "tailwind framework --minify",
        "esbuild framework --minify",
        "phx.digest"
      ],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"]
    ]
  end

  def get_hash do
    {hash, _} = System.cmd("git", ["rev-parse", "--short=8", "HEAD"])
    String.trim(hash)
  catch
    _x -> ""
  end
end
