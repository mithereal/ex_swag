defmodule <%= @web_module_prefix %>.PhoenixKit.Advanced.Dashboard.<%= @page_name %> do
  @moduledoc """
  User dashboard LiveView for <%= @page_title %>.
  """

  use <%= @web_module_prefix %>, :live_view

  alias PhoenixKit.Utils.Widget
  alias PhoenixKit.Dashboard.Widget.Layout

  import PhoenixKitWeb.LayoutHelpers, only: [dashboard_assigns: 1]
  import PhoenixKitWeb.Components.Core.UserDashboardHeader,
    only: [user_dashboard_header: 1]

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.phoenix_kit_current_user

    socket =
      socket
      |> assign(
        page_title: @page_title,
        widgets: Layout.widgets_for(user),
        available: Widget.load_all_widgets(),
        selected: MapSet.new()
      )
       |> assign(:grid_options, %{
        float: false,
        cellHeight: 80,
        verticalMargin: 10,
        disableOneColumnMode: false
      })


    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <PhoenixKitWeb.Layouts.dashboard {dashboard_assigns(assigns)}>
      <div class="flex max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 gap-6">

        <!-- MAIN CONTENT -->
        <div class="flex-1 min-w-0">
          <.user_dashboard_header
            title={@page_title}
          />

          <!-- GRID -->
<div
            phx-hook="GridStack"
            id="grid"
            data-options={Jason.encode!(@grid_config)}
            class="grid-stack bg-white rounded p-4 min-h-96"
          ><%= for w <- @widgets do %>
              <div
                id={w.uuid}
                class="grid-stack-item"
                data-config='{"minW": 1, "minH": 1}'
                data-uuid={w.uuid}
                data-name={w.name}
                phx-hook="GridStackItem"
                gs-x={w.x}
                gs-y={w.y}
                gs-w={w.w}
                gs-h={w.h}
              >
                <div class="grid-stack-item-content">
                  <.dashboard_stack item={w} />
                </div>
              </div>
            <% end %>
          </div>
        </div>
    <div :if={Enum.count(@available) > 0}>
        <!-- Toggle Button -->
       <div class={[
          "w-80 shrink-0 transition-all duration-300",
          @show_sidebar && "translate-x-0",
          !@show_sidebar && "translate-x-0 lg:translate-x-0"
        ]} :if={!@show_sidebar}>
     <button class="btn btn-xs btn-ghost" phx-click="toggle_sidebar">
                    ☰
                  </button>
                </div>
        <!-- RIGHT GUTTER -->
        <div class={[
          "w-80 shrink-0 transition-all duration-300",
          @show_sidebar && "translate-x-0",
          !@show_sidebar && "translate-x-0 lg:translate-x-0"
        ]}>

          <div class="sticky top-4">
            <div class="card bg-base-100 shadow-md border border-base-300">
              <div class="card-body p-4">

                <!-- Header -->
                <div class="flex items-center justify-between mb-2">
                  <h3 class="font-semibold text-base">Available Widgets</h3>

                  <button
                    class="btn btn-xs btn-ghost"
                    phx-click="toggle_sidebar"
                  >
                    →
                  </button>
                </div>

                <!-- Widget List (DRAG SOURCE) -->
                <div class="space-y-2 max-h-[500px] overflow-y-auto">

                  <%= for w <- @available do %>
                    <div
                      class="flex items-center justify-between p-2 rounded-lg hover:bg-base-200 transition cursor-grab"
                      data-widget-uuid={w.uuid}
                      data-widget-name={w.name}
                    >
                      <div>
                        <div class="font-medium text-sm">
                          <%= w.name %>
                        </div>
                        <div class="text-xs opacity-60">
                          <%= w.description %>
                        </div>
                      </div>

                      <button
                        class="btn btn-xs btn-primary"
                        phx-click="add_widget"
                        phx-value-widget={w.uuid}
                      >
                        Add
                      </button>
                    </div>
                  <% end %>

                </div>

              </div>
            </div>
          </div>
        </div>

      </div>
      </div>

      <!-- MOBILE FLOAT BUTTON -->
      <button
        class="fixed bottom-6 right-6 btn btn-primary btn-circle shadow-lg lg:hidden"
        phx-click="toggle_sidebar"
      >
        +
      </button>

    </PhoenixKitWeb.Layouts.dashboard>
    """
  end

  defp dashboard_stack(assigns) do
    ~H"""
    <div class="card bg-base-100 shadow-sm border border-base-300 h-full">
      <div class="card-body p-3">
        <div class="flex items-center justify-between">
          <span class="font-semibold text-sm">
            <%= @item.title %>
          </span>

          <button
            class="btn btn-xs btn-ghost"
            phx-click="remove_widget"
            phx-value-uuid={@item.uuid}
          >
            ×
          </button>
        </div>

        <div class="text-xs opacity-60 mt-2">
          <%= @item.description %>
        </div>
      </div>
    </div>
    """
  end


  def handle_event("toggle_sidebar", _params, socket) do
    sidebar_open = !socket.assigns.sidebar_open
    Grids.update_sidebar(socket.assigns.user_id, sidebar_open)
    {:noreply, assign(socket, sidebar_open: sidebar_open)}
  end

  def handle_event("add_widget", %{"type" => widget_type}, socket) do
    {:ok, widget} =
      Grids.upsert_widget(socket.assigns.grid_layout.uuid, nil, %{
        widget_type: widget_type,
        x: 0,
        y: 0,
        w: 2,
        h: 2
      })

    item = widget_to_item(widget)

    socket =
      socket
      |> push_event("add_item", %{
        id: widget.uuid,
        x: item.x,
        y: item.y,
        w: item.w,
        h: item.h,
        content: "<h3 class='font-bold'>#{widget_type}</h3>"
      })
      |> update(:grid_items, &(&1 ++ [item]))

    {:noreply, socket}
  end

  def handle_event("grid:item_resized", %{"id" => id, "x" => x, "y" => y, "w" => w, "h" => h}, socket) do
    Grids.upsert_widget(socket.assigns.grid_layout.uuid, id, %{
      x: x,
      y: y,
      w: w,
      h: h,
      widget_type: "default"
    })

    {:noreply, socket}
  end

  def handle_event("grid:item_moved", %{"id" => id, "x" => x, "y" => y}, socket) do
    Grids.upsert_widget(socket.assigns.grid_layout.uuid, id, %{
      x: x,
      y: y,
      w: 2,
      h: 2,
      widget_type: "default"
    })

    {:noreply, socket}
  end

  def handle_event("grid:item_removed", %{"id" => id}, socket) do
    try do
      Grids.delete_widget(id)
    rescue
      _ -> :ok
    end

    {:noreply, socket}
  end

  def handle_event("grid:changed", %{"items" => items}, socket) do
    Grids.batch_update_widgets(socket.assigns.grid_layout.uuid, items)
    {:noreply, socket}
  end

  defp widget_to_item(widget) do
    %{
      uuid: widget.uuid,
      x: widget.x,
      y: widget.y,
      w: widget.w,
      h: widget.h,
      widget_type: widget.widget_type
    }
  end

end