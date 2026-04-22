defmodule FrameworkWeb.Router do
  use FrameworkWeb, :router

  import PhoenixKitWeb.Integration

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {FrameworkWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PhoenixKitWeb.Plugs.Integration
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FrameworkWeb do
    pipe_through :browser
    get "/", PageController, :index
    get "/investors", PageController, :funding
  end

  #  scope "/print-services", FrameworkWeb do
  #    pipe_through [:browser, :require_authenticated_user]
  #
  #    live_session :print_services,
  #                 on_mount: [
  #                   {PhoenixKitWeb.Users.Auth, :mount_current_scope},
  #                   {PhoenixKitWeb.Users.Auth, :ensure_authenticated_scope}
  #                 ] do
  #      # Print Services
  #      live "/", ServicesLive.Index, :index
  #      live "/new", ServicesLive.New, :new
  #      live "/:id/edit", ServicesLive.Edit, :edit
  #      live "/:id", ServicesLive.Show, :show
  #
  #      # Orders
  #      live "/orders", OrdersLive.Index, :index
  #      live "/orders/new", OrdersLive.New, :new
  #      live "/orders/:id", OrdersLive.Show, :show
  #
  #      # Quotes
  #      live "/quotes", QuotesLive.Index, :index
  #      live "/quotes/:id", QuotesLive.Show, :show
  #
  #      # Materials
  #      live "/materials", MaterialsLive.Index, :index
  #    end
  #  end

  # Other scopes may use custom stacks.
  # scope "/api", FrameworkWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:framework, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FrameworkWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # PhoenixKit Demo Pages - Test Authentication Levels
  scope "/" do
    pipe_through :browser

    live_session :current_scope,
      on_mount: [{FrameworkWeb.Users.Auth, :phoenix_kit_mount_current_scope}] do
      live "/test-current-user", FrameworkWeb.PhoenixKitLive.TestRequireAuthLive, :index
    end

    live_session :redirect_if_auth_scope,
      on_mount: [{FrameworkWeb.Users.Auth, :phoenix_kit_redirect_if_authenticated_scope}] do
      live "/test-redirect-if-auth", FrameworkWeb.PhoenixKitLive.TestRedirectIfAuthLive, :index
    end

    live_session :ensure_auth_scope,
      on_mount: [{FrameworkWeb.Users.Auth, :phoenix_kit_ensure_authenticated_scope}] do
      live "/home/dashboard", FrameworkWeb.Dashboard.User, :index
      live "/home/quote/:id", FrameworkWeb.Quotes.Show, :show
      live "/proof/:id", FrameworkWeb.DesignProofLive, :show
      live "/home/services", FrameworkWeb.ServicesLive.Index, :index
      live "/home/sales", FrameworkWeb.Dashboard.Sales, :index
      live "/home/inventory", FrameworkWeb.Inventory.Live.InventoryLive, :index
      live "/home/materials", FrameworkWeb.MaterialsLive.Index, :index
      live "/home/test-ensure-auth", FrameworkWeb.PhoenixKitLive.TestEnsureAuthLive, :index
    end
  end

  phoenix_kit_routes()
end
