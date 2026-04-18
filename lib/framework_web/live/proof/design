defmodule FrameworkWeb.DesignProofLive do
  @moduledoc """
  Embedded LiveView client for design proofing.

  Can be used in two ways:
  1. As a standalone page: mount in router with live "/designs/proof/:id", DesignProofClientLive
  2. As an embedded component: live_render in another LiveView with live_render(conn, FrameworkWeb.DesignProofClientLive, session: %{"design_id" => "123"})

  Usage in parent LiveView:

    <%= live_render(@socket, FrameworkWeb.DesignProofClientLive,
      session: %{"design_id" => @design.id, "user_id" => @current_user.id}) %>
  """

  use FrameworkWeb, :live_view
  use PhoenixKitWeb, :live_view
  require Logger

  alias FrameworkWeb.Components.DesignProof

  @impl true
  def mount(params, session, socket) do
    design_id = params["id"] || session["design_id"]

    unless connected?(socket) do
      Logger.debug("DesignProofLive mounted (not connected yet)")
    end

    {:ok,
     socket
     |> assign(
       design: %{
         id: design_id || "design_001",
         name: "Business Card - Premium",
         thumbnail: "/images/design-thumb.jpg",
         fullsize: "/images/design-full.jpg",
         notes:
           "Premium business card design with gold foil accents. Final mockup ready for approval.",
         status: "ready",
         created_at: DateTime.utc_now()
       },
       settings: %{
         color_mode: "rgb",
         show_guides: false,
         zoom_level: 100,
         display_notes: true,
         client_name: "Acme Corporation",
         approval_required: true
       },
       page: :proof,
       notifications: []
     )}
  end

  # Navigation Events
  @impl true
  def handle_event("navigate_to_proof", _params, socket) do
    {:noreply, assign(socket, page: :proof)}
  end

  @impl true
  def handle_event("navigate_to_settings", _params, socket) do
    {:noreply, assign(socket, page: :settings)}
  end

  # Display Events
  @impl true
  def handle_event("toggle_guides", _params, socket) do
    settings = socket.assigns.settings
    updated = Map.put(settings, :show_guides, !settings.show_guides)
    {:noreply, assign(socket, settings: updated)}
  end

  @impl true
  def handle_event("toggle_notes", _params, socket) do
    settings = socket.assigns.settings
    updated = Map.put(settings, :display_notes, !settings.display_notes)
    {:noreply, assign(socket, settings: updated)}
  end

  @impl true
  def handle_event("set_zoom", %{"value" => value}, socket) do
    zoom = String.to_integer(value)
    settings = socket.assigns.settings
    updated = Map.put(settings, :zoom_level, zoom)
    {:noreply, assign(socket, settings: updated)}
  end

  # Color Mode
  @impl true
  def handle_event("set_color_mode", %{"mode" => mode}, socket) do
    settings = socket.assigns.settings
    updated = Map.put(settings, :color_mode, mode)
    {:noreply, assign(socket, settings: updated)}
  end

  # Settings
  @impl true
  def handle_event("update_client_name", %{"value" => name}, socket) do
    settings = socket.assigns.settings
    updated = Map.put(settings, :client_name, name)
    {:noreply, assign(socket, settings: updated)}
  end

  @impl true
  def handle_event("toggle_approval_required", _params, socket) do
    settings = socket.assigns.settings
    updated = Map.put(settings, :approval_required, !settings.approval_required)
    {:noreply, assign(socket, settings: updated)}
  end

  @impl true
  def handle_event("save_settings", _params, socket) do
    Logger.info("Settings saved: #{inspect(socket.assigns.settings)}")

    socket =
      socket
      |> put_flash(:info, "Settings saved successfully!")

    {:noreply, socket}
  end

  # Approval Events
  @impl true
  def handle_event("approve_design", _params, socket) do
    design = socket.assigns.design
    updated_design = Map.put(design, :status, "approved")

    Logger.info("Design approved: #{design.id}")

    socket =
      socket
      |> assign(design: updated_design)
      |> put_flash(:info, "Design approved successfully!")

    {:noreply, socket}
  end

  @impl true
  def handle_event("reject_design", %{"reason" => reason}, socket) do
    design = socket.assigns.design

    updated_design =
      design
      |> Map.put(:status, "rejected")
      |> Map.put(:rejection_reason, reason)

    Logger.info("Design rejected: #{design.id}, Reason: #{reason}")

    socket =
      socket
      |> assign(design: updated_design)
      |> put_flash(:error, "Design rejected. Reason: #{reason}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("download_design", _params, socket) do
    Logger.info("Design download initiated: #{socket.assigns.design.id}")

    socket =
      socket
      |> put_flash(:info, "Download started...")

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <PhoenixKitWeb.Layouts.dashboard {dashboard_assigns(assigns)}>
      <div class="h-screen bg-gradient-to-br from-slate-50 to-slate-100">
        <!-- Header -->


      <!-- Flash Messages -->
        <%= if live_flash(@flash, :info) do %>
          <div class="mx-auto max-w-7xl px-6 py-4 mt-4">
            <div class="rounded-lg bg-green-50 border border-green-200 p-4 text-green-800">
              {live_flash(@flash, :info)}
            </div>
          </div>
        <% end %>

        <%= if live_flash(@flash, :error) do %>
          <div class="mx-auto max-w-7xl px-6 py-4 mt-4">
            <div class="rounded-lg bg-red-50 border border-red-200 p-4 text-red-800">
              {live_flash(@flash, :error)}
            </div>
          </div>
        <% end %>
        
    <!-- Main Content -->
        <main class="mx-auto max-w-7xl px-6 py-8"></main>
      </div>
    </PhoenixKitWeb.Layouts.dashboard>
    """
  end

  # Component helpers
  defp design_canvas(assigns) do
    ~H"""
    <.design_canvas {assigns} />
    """
  end

  defp approval_sidebar(assigns) do
    ~H"""
    <.approval_sidebar {assigns} />
    """
  end

  defp settings_form(assigns) do
    ~H"""
    <.settings_form {assigns} />
    """
  end
end
