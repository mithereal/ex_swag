# lib/FrameworkWeb_web/live/print_services_live/index.ex

defmodule FrameworkWeb.ServicesLive.Index do
  use PhoenixKitWeb, :live_view
  import FrameworkWeb.Components.Services
  alias Framework.Services

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Print Services")
     |> stream(:services, Services.list_print_services())}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <PhoenixKitWeb.Layouts.dashboard {dashboard_assigns(assigns)}>
      <div class="max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="min-h-screen ">
          <.header>
            Print Services
            <:subtitle>Manage all print service offerings</:subtitle>
            <:actions>
              <.link navigate="/print-services/new" class="btn btn-primary align-right">
                New Service
              </.link>
            </:actions>
          </.header>

          <.services_table id="services" rows={@streams.services} />
        </div>
      </div>
    </PhoenixKitWeb.Layouts.dashboard>
    """
  end
end
