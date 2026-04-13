defmodule FrameworkWeb.Components.DesignProof do
  @moduledoc """
  Reusable LiveView components for design proofing workflows.
  Can be embedded in other LiveViews or used standalone.
  """

  use FrameworkWeb, :html

  attr :design, :map, required: true, doc: "Design data map with id, name, fullsize, status"
  attr :settings, :map, required: true, doc: "Settings map with zoom_level, show_guides, etc"
  attr :on_zoom_change, :any, required: true, doc: "Event handler for zoom changes"
  attr :on_toggle_guides, :any, required: true, doc: "Event handler for guide toggle"
  attr :on_toggle_notes, :any, required: true, doc: "Event handler for note toggle"

  def design_canvas(assigns) do
    ~H"""
    <div class="overflow-hidden rounded-2xl bg-white shadow-lg">
      <!-- Toolbar -->
      <div class="border-b border-slate-200 bg-slate-50 px-6 py-4">
        <div class="flex flex-wrap items-center justify-between gap-4">
          <!-- Zoom Controls -->
          <div class="flex items-center gap-3">
            <label class="text-sm font-medium text-slate-700">Zoom:</label>
            <input
              type="range"
              min="50"
              max="200"
              step="10"
              value={@settings.zoom_level}
              phx-change={@on_zoom_change}
              class="h-2 w-32 cursor-pointer rounded-lg bg-slate-200 accent-blue-600"
            />
            <span class="w-12 text-right text-sm font-semibold text-slate-700">
              {@settings.zoom_level}%
            </span>
          </div>
          
    <!-- Display Options -->
          <div class="flex items-center gap-4">
            <label class="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={@settings.show_guides}
                phx-click={@on_toggle_guides}
                class="h-4 w-4 rounded border-slate-300 accent-blue-600"
              />
              <span class="text-sm text-slate-700">Show Guides</span>
            </label>
            <label class="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={@settings.display_notes}
                phx-click={@on_toggle_notes}
                class="h-4 w-4 rounded border-slate-300 accent-blue-600"
              />
              <span class="text-sm text-slate-700">Notes</span>
            </label>
          </div>
        </div>
      </div>
      
    <!-- Design Image Container -->
      <div class="flex items-center justify-center bg-gradient-to-br from-white to-slate-50 p-12 min-h-96">
        <div class="relative">
          <img
            src={@design.fullsize}
            alt={@design.name}
            style={"transform: scale(#{@settings.zoom_level / 100})"}
            class="max-w-2xl transition-transform duration-200"
          />
          <%= if @settings.show_guides do %>
            <div class="pointer-events-none absolute inset-0 border-2 border-dashed border-amber-400 opacity-50">
            </div>
          <% end %>
        </div>
      </div>
      
    <!-- Notes Section -->
      <%= if @settings.display_notes do %>
        <div class="border-t border-slate-200 bg-blue-50 px-6 py-4">
          <h3 class="mb-2 font-semibold text-slate-900">Design Notes</h3>
          <p class="text-sm text-slate-700">
            {@design.notes || "No notes provided for this design."}
          </p>
        </div>
      <% end %>
    </div>
    """
  end

  attr :design, :map, required: true, doc: "Design data with status"
  attr :on_approve, :any, required: true, doc: "Event handler for approve"
  attr :on_reject, :any, required: true, doc: "Event handler for reject"
  attr :on_download, :any, required: true, doc: "Event handler for download"

  def approval_sidebar(assigns) do
    ~H"""
    <aside class="space-y-6">
      <!-- Approval Section -->
      <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
        <h3 class="mb-4 font-semibold text-slate-900">Approval</h3>
        <div class="space-y-3">
          <%= if @design.status == "ready" do %>
            <button
              phx-click={@on_approve}
              class="w-full rounded-lg bg-gradient-to-r from-green-500 to-green-600 px-4 py-3 font-semibold text-white transition-all hover:shadow-lg hover:from-green-600 hover:to-green-700 active:scale-95"
            >
              ✓ Approve Design
            </button>
            <button
              phx-click={@on_reject}
              phx-value-reason="Needs revision"
              class="w-full rounded-lg border-2 border-red-200 px-4 py-3 font-semibold text-red-700 transition-all hover:bg-red-50 active:scale-95"
            >
              ✕ Request Changes
            </button>
          <% else %>
            <div class="rounded-lg bg-slate-50 px-4 py-3 text-center text-sm text-slate-600">
              {case @design.status do
                "approved" -> "✓ Design Approved"
                "rejected" -> "✕ Changes Requested"
                _ -> "Status: #{String.capitalize(@design.status)}"
              end}
            </div>
          <% end %>
        </div>
      </div>
      
    <!-- Download -->
      <button
        phx-click={@on_download}
        class="w-full rounded-lg border-2 border-slate-300 px-4 py-3 font-semibold text-slate-700 transition-all hover:border-slate-400 hover:bg-slate-50 active:scale-95"
      >
        ⬇ Download Proof
      </button>
      
    <!-- Design Info -->
      <div class="rounded-xl border border-slate-200 bg-slate-50 p-6">
        <h3 class="mb-3 text-sm font-semibold text-slate-700">Design Info</h3>
        <div class="space-y-2 text-xs text-slate-600">
          <div class="flex justify-between">
            <span>ID:</span>
            <span class="font-mono font-semibold">{@design.id}</span>
          </div>
          <div class="flex justify-between">
            <span>Status:</span>
            <span class="font-semibold">{String.capitalize(@design.status)}</span>
          </div>
          <%= if @design.created_at do %>
            <div class="flex justify-between">
              <span>Created:</span>
              <span>{Calendar.strftime(@design.created_at, "%b %d, %Y")}</span>
            </div>
          <% end %>
        </div>
      </div>
    </aside>
    """
  end

  attr :settings, :map, required: true, doc: "Settings map"
  attr :on_color_mode_change, :any, required: true, doc: "Event handler for color mode"
  attr :on_client_name_change, :any, required: true, doc: "Event handler for client name"

  attr :on_toggle_approval_required, :any,
    required: true,
    doc: "Event handler for approval toggle"

  attr :on_save, :any, required: true, doc: "Event handler for save"
  attr :on_cancel, :any, required: true, doc: "Event handler for cancel"

  def settings_form(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl rounded-2xl bg-white p-8 shadow-lg">
      <h2 class="mb-8 text-2xl font-bold text-slate-900">Proof Settings</h2>

      <form phx-submit={@on_save} class="space-y-8">
        <!-- Client Information -->
        <div class="space-y-4 border-b border-slate-200 pb-8">
          <h3 class="font-semibold text-slate-900">Client Information</h3>
          <div>
            <label class="block text-sm font-medium text-slate-700 mb-2">
              Client Name
            </label>
            <input
              type="text"
              value={@settings.client_name}
              phx-change={@on_client_name_change}
              class="w-full rounded-lg border-2 border-slate-200 px-4 py-2 text-slate-900 placeholder-slate-400 transition-colors focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
              placeholder="Enter client name"
            />
          </div>
        </div>
        
    <!-- Color & Format -->
        <div class="space-y-4 border-b border-slate-200 pb-8">
          <h3 class="font-semibold text-slate-900">Color & Format</h3>

          <div>
            <label class="block text-sm font-medium text-slate-700 mb-3">
              Color Mode
            </label>
            <div class="space-y-2">
              <label
                class="flex items-center gap-3 cursor-pointer p-3 rounded-lg border-2 border-slate-200 hover:border-blue-300 hover:bg-blue-50 transition-colors"
                style={"border-color: #{if @settings.color_mode == "rgb" do "rgb(59, 130, 246)" else "rgb(226, 232, 240)" end}"}
              >
                <input
                  type="radio"
                  name="color_mode"
                  value="rgb"
                  checked={@settings.color_mode == "rgb"}
                  phx-change={@on_color_mode_change}
                  class="h-4 w-4 accent-blue-600"
                />
                <div>
                  <span class="font-medium text-slate-900">RGB</span>
                  <p class="text-xs text-slate-500">For digital displays</p>
                </div>
              </label>

              <label
                class="flex items-center gap-3 cursor-pointer p-3 rounded-lg border-2 border-slate-200 hover:border-blue-300 hover:bg-blue-50 transition-colors"
                style={"border-color: #{if @settings.color_mode == "cmyk" do "rgb(59, 130, 246)" else "rgb(226, 232, 240)" end}"}
              >
                <input
                  type="radio"
                  name="color_mode"
                  value="cmyk"
                  checked={@settings.color_mode == "cmyk"}
                  phx-change={@on_color_mode_change}
                  class="h-4 w-4 accent-blue-600"
                />
                <div>
                  <span class="font-medium text-slate-900">CMYK</span>
                  <p class="text-xs text-slate-500">For print materials</p>
                </div>
              </label>
            </div>
          </div>
        </div>
        
    <!-- Approval Settings -->
        <div class="space-y-4 pb-8">
          <h3 class="font-semibold text-slate-900">Approval Settings</h3>

          <label class="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={@settings.approval_required}
              phx-click={@on_toggle_approval_required}
              class="h-5 w-5 rounded border-slate-300 accent-blue-600"
            />
            <div>
              <span class="font-medium text-slate-900">Require Client Approval</span>
              <p class="text-sm text-slate-500">
                Design cannot be sent to production without approval
              </p>
            </div>
          </label>
        </div>
        
    <!-- Save Button -->
        <div class="flex gap-3 pt-8">
          <button
            type="submit"
            class="flex-1 rounded-lg bg-gradient-to-r from-blue-600 to-blue-700 px-6 py-3 font-semibold text-white transition-all hover:shadow-lg hover:from-blue-700 hover:to-blue-800 active:scale-95"
          >
            Save Settings
          </button>
          <button
            type="button"
            phx-click={@on_cancel}
            class="px-6 py-3 rounded-lg border-2 border-slate-300 font-semibold text-slate-700 transition-all hover:bg-slate-50 active:scale-95"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
    """
  end

  attr :color_mode, :string, required: true, doc: "Current color mode"
  attr :on_change, :any, required: true, doc: "Event handler for changes"

  def color_mode_selector(assigns) do
    ~H"""
    <div class="rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
      <h3 class="mb-4 font-semibold text-slate-900">Color Mode</h3>
      <div class="space-y-2">
        <label class="flex items-center gap-3 cursor-pointer">
          <input
            type="radio"
            name="color_mode"
            value="rgb"
            checked={@color_mode == "rgb"}
            phx-change={@on_change}
            class="h-4 w-4 accent-blue-600"
          />
          <span class="text-sm text-slate-700">RGB</span>
        </label>
        <label class="flex items-center gap-3 cursor-pointer">
          <input
            type="radio"
            name="color_mode"
            value="cmyk"
            checked={@color_mode == "cmyk"}
            phx-change={@on_change}
            class="h-4 w-4 accent-blue-600"
          />
          <span class="text-sm text-slate-700">CMYK</span>
        </label>
      </div>
    </div>
    """
  end

  attr :status, :string, required: true, doc: "Design status"
  attr :created_at, :any, doc: "Design creation date"
  attr :id, :string, required: true, doc: "Design ID"

  def design_info_card(assigns) do
    ~H"""
    <div class="rounded-xl border border-slate-200 bg-slate-50 p-6">
      <h3 class="mb-3 text-sm font-semibold text-slate-700">Design Info</h3>
      <div class="space-y-2 text-xs text-slate-600">
        <div class="flex justify-between">
          <span>ID:</span>
          <span class="font-mono font-semibold">{@id}</span>
        </div>
        <div class="flex justify-between">
          <span>Status:</span>
          <span class="font-semibold">{String.capitalize(@status)}</span>
        </div>
        <%= if @created_at do %>
          <div class="flex justify-between">
            <span>Created:</span>
            <span>{Calendar.strftime(@created_at, "%b %d, %Y")}</span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  attr :status, :string, required: true, doc: "Design status badge"

  def status_badge(assigns) do
    ~H"""
    <span class={
        "inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold #{
          case @status do
            "ready" -> "bg-green-100 text-green-800"
            "approved" -> "bg-blue-100 text-blue-800"
            "rejected" -> "bg-red-100 text-red-800"
            _ -> "bg-slate-100 text-slate-800"
          end
        }"
      }>
      {String.capitalize(@status)}
    </span>
    """
  end

  attr :on_approve, :any, required: true, doc: "Approve handler"
  attr :on_reject, :any, required: true, doc: "Reject handler"
  attr :status, :string, required: true, doc: "Current status"

  def approval_buttons(assigns) do
    ~H"""
    <div class="space-y-3">
      <%= if @status == "ready" do %>
        <button
          phx-click={@on_approve}
          class="w-full rounded-lg bg-gradient-to-r from-green-500 to-green-600 px-4 py-3 font-semibold text-white transition-all hover:shadow-lg hover:from-green-600 hover:to-green-700 active:scale-95"
        >
          ✓ Approve Design
        </button>
        <button
          phx-click={@on_reject}
          phx-value-reason="Needs revision"
          class="w-full rounded-lg border-2 border-red-200 px-4 py-3 font-semibold text-red-700 transition-all hover:bg-red-50 active:scale-95"
        >
          ✕ Request Changes
        </button>
      <% else %>
        <div class="rounded-lg bg-slate-50 px-4 py-3 text-center text-sm text-slate-600">
          {case @status do
            "approved" -> "✓ Design Approved"
            "rejected" -> "✕ Changes Requested"
            _ -> "Status: #{String.capitalize(@status)}"
          end}
        </div>
      <% end %>
    </div>
    """
  end

  attr :title, :string, required: true, doc: "Header title"
  attr :subtitle, :string, doc: "Header subtitle"
  attr :status, :string, doc: "Status badge value"
  attr :nav_items, :list, required: true, doc: "Navigation items as [{label, event}]"
  attr :active_tab, :string, doc: "Currently active tab"

  def header(assigns) do
    ~H"""
    <header class="sticky top-0 z-40 border-b border-slate-200 bg-white shadow-sm">
      <div class="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
        <div class="flex items-center gap-3">
          <div class="flex h-10 w-10 items-center justify-center rounded-lg bg-gradient-to-br from-blue-600 to-blue-700">
            <span class="font-bold text-white">FW</span>
          </div>
          <div>
            <h1 class="text-lg font-semibold text-slate-900">{@title}</h1>
            <%= if @subtitle do %>
              <p class="text-sm text-slate-500">{@subtitle}</p>
            <% end %>
          </div>
        </div>
        
    <!-- Navigation Tabs -->
        <nav class="flex gap-2">
          <%= for {label, event} <- @nav_items do %>
            <button
              phx-click={event}
              class={
                "rounded-lg px-4 py-2 text-sm font-medium transition-all #{
                  if @active_tab == event do
                    "bg-blue-100 text-blue-700 shadow-sm"
                  else
                    "text-slate-600 hover:bg-slate-100"
                  end
                }"
              }
            >
              {label}
            </button>
          <% end %>
        </nav>
        
    <!-- Status Badge -->
        <%= if @status do %>
          <.status_badge status={@status} />
        <% end %>
      </div>
    </header>
    """
  end
end
