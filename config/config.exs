# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :swoosh, api_client: Swoosh.ApiClient.Finch

config :phoenix_kit,
  parent_app_name: :framework,
  parent_module: Framework,
  url_prefix: "/home",
  repo: Framework.Repo,
  mailer: Framework.Mailer,
  project_title: "Swag Craft",
  layouts_module: FrameworkWeb.Layouts,
  phoenix_version_strategy: :modern,
  user_dashboard_categories: [
    %{
      tabs: [
        %{description: nil, title: "Jobs", url: "/dashboard", icon: "hero-document"},
        %{description: nil, title: "Jobs", url: "/dashboard", icon: "hero-document"},
        %{description: nil, title: "Tasks", url: "/dashboard", icon: "hero-document"},
        %{description: nil, title: "Approvals", url: "/dashboard", icon: "hero-document"},
        %{description: nil, title: "Packages", url: "/dashboard", icon: ""}
      ],
      title: "Production",
      icon: "hero-folder"
    }
  ]

config :framework,
  ecto_repos: [Framework.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :framework, FrameworkWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: FrameworkWeb.ErrorHTML, json: FrameworkWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Framework.PubSub,
  live_view: [signing_salt: "TYQnU2mp"]

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
# config :framework, Framework.Mailer, adapter: Swoosh.Adapters.Local

config :framework, Framework.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  framework: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  framework: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Configure rate limiting with Hammer
config :hammer,
  backend:
    {Hammer.Backend.ETS,
     [
       # Cleanup expired rate limit buckets every 60 seconds
       expiry_ms: 60_000,
       # Cleanup interval (1 minute)
       cleanup_interval_ms: 60_000
     ]}

# Configure rate limits for authentication endpoints
config :phoenix_kit, PhoenixKit.Users.RateLimiter,
  # Login: 5 attempts per minute per email
  login_limit: 5,
  login_window_ms: 60_000,
  # Magic link: 3 requests per 5 minutes per email
  magic_link_limit: 3,
  magic_link_window_ms: 300_000,
  # Password reset: 3 requests per 5 minutes per email
  password_reset_limit: 3,
  password_reset_window_ms: 300_000,
  # Registration: 3 attempts per hour per email
  registration_limit: 3,
  registration_window_ms: 3_600_000,
  # Registration IP: 10 attempts per hour per IP
  registration_ip_limit: 10,
  registration_ip_window_ms: 3_600_000

# Configure Ueberauth (minimal configuration for compilation)
# OAuth providers are configured dynamically at runtime from database
config :ueberauth, Ueberauth, providers: %{}
# Configure Oban for PhoenixKit background jobs
# Required for file processing (storage system), posts, and sitemap
config :framework, Oban,
  repo: Framework.Repo,
  queues: [
    # General purpose queue
    default: 10,

    # File variant generation (storage system)
    file_processing: 20,

    # Posts scheduled publishing
    posts: 10,

    # Scheduled jobs cron
    scheduled_jobs: 1,

    # Sitemap generation
    sitemap: 5,

    # Newsletters broadcast deliveries
    newsletters_delivery: 10,
    shop_imports: 2
  ],
  plugins: [
    # Pruner: delete completed/discarded jobs after 30 days
    {Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 30},
    {Oban.Plugins.Cron,
     crontab: [
       {"* * * * *", PhoenixKit.ScheduledJobs.Workers.ProcessScheduledJobsWorker}
     ]}
  ]

config :phoenix_kit,
  redirect: [
    after_login_path: "/home"
  ]

import_config "#{config_env()}.exs"
