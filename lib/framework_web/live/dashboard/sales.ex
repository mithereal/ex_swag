defmodule FrameworkWeb.Dashboard.Sales do
  @moduledoc """
  Sales dashboard LiveView for user.
  """

  use FrameworkWeb, :live_view
  use PhoenixKitWeb.Components.Dashboard.LiveTabs

  alias PhoenixKit.Dashboard.Widget
  alias Framework.Schema.Layout

  import PhoenixKitWeb.LayoutHelpers, only: [dashboard_assigns: 1]

  import PhoenixKitWeb.Components.Core.UserDashboardHeader,
    only: [user_dashboard_header: 1]

  @page "Sales Dashboard"

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.phoenix_kit_current_user

    socket =
      assign(socket,
        show_sidebar: true
      )

    layout =
      case Layout.layout_for(user, @page) do
        nil -> Framework.System.create_layout(user, @page)
        layout -> layout
      end

    grid_items = Framework.Dashboard.Grid.from_layout(layout)

    socket =
      socket
      |> assign(
        page_title: @page,
        grid_items: grid_items,
        available:
          Framework.Schema.Widget.diff_widgets(
            grid_items,
            Widget.load_all_widgets()
          ),
        selected: MapSet.new(),
        layout_uuid: layout.uuid
      )
      |> assign(:grid_options, %{
        float: false,
        cellHeight: 80,
        margin: 10,
        disableOneColumnMode: true,
        resizable: %{handles: "all"},
        draggable: %{handle: ".grid-stack-item-content"}
      })

    {:ok, socket}
  end

  # ------------------------
  # Sidebar persistence
  # ------------------------

  def handle_event("toggle_sidebar", _, socket) do
    new_state = !socket.assigns.show_sidebar

    socket =
      socket
      |> assign(:show_sidebar, new_state)
      |> push_event("persist:save", %{
        key: "sidebar:collapsed",
        value: new_state
      })

    {:noreply, socket}
  end

  def handle_event("persist:load", %{"key" => "sidebar:collapsed", "value" => val}, socket) do
    {:noreply, assign(socket, show_sidebar: val)}
  end

  # ------------------------
  # Grid events
  # ------------------------

  def handle_event(
        "grid:item_resized",
        %{"id" => id, "w" => w, "h" => h, "x" => x, "y" => y},
        socket
      ) do
    IO.inspect({:resized, id, w, h, x, y})

    # Update local state
    socket =
      socket
      |> update(:grid_items, fn items ->
        Enum.map(items, fn item ->
          if item.id == id or "widget-#{item.uuid}" == id,
            do: %{item | w: to_integer(w), h: to_integer(h), x: to_integer(x), y: to_integer(y)},
            else: item
        end)
      end)
      |> persist_grid_layout()

    {:noreply, socket}
  end

  def handle_event("grid:item_moved", %{"id" => id, "x" => x, "y" => y} = params, socket) do
    IO.inspect({:moved, id, x, y})

    w = params["w"]
    h = params["h"]

    socket =
      socket
      |> update(:grid_items, fn items ->
        Enum.map(items, fn item ->
          if item.id == id or "widget-#{item.uuid}" == id do
            item_update = %{item | x: to_integer(x), y: to_integer(y)}

            # Only update dimensions if provided
            item_update =
              if w, do: %{item_update | w: to_integer(w)}, else: item_update

            if h, do: %{item_update | h: to_integer(h)}, else: item_update
          else
            item
          end
        end)
      end)
      |> persist_grid_layout()

    {:noreply, socket}
  end

  def handle_event(
        "grid:item_added",
        %{"widget" => uuid, "layout" => layout_uuid} = params,
        socket
      ) do
    widget = Widget.get_widget(uuid)

    socket =
      if(widget) do
        # if(widget && !widget_in_grid) do
        user = socket.assigns.phoenix_kit_current_user

        Framework.System.add_widget(uuid, layout_uuid)

        #        grid_items =
        #          Layout.layout_for(user, @page)
        #          |> Framework.Dashboard.Grid.from_layout()

        widget = Map.put(widget, :layout_uuid, layout_uuid)

        grid_items =
          socket.assigns.grid_items ++ [%{uuid: uuid, w: 2, h: 2, x: nil, y: nil, widget: widget}]

        socket
        |> assign(
          grid_items: grid_items,
          available: Framework.Schema.Widget.diff_widgets(grid_items, Widget.load_all_widgets()),
          selected: MapSet.new()
        )
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("grid:item_double_clicked", %{"id" => id}, socket) do
    IO.inspect({:double_clicked, id})
    {:noreply, socket}
  end

  def handle_event("grid:changed", %{"items" => items}, socket) do
    # This event is fired whenever the grid layout changes
    # Update local state without persisting yet (wait for dragstop/resizestop)
    IO.inspect({:grid_changed, items})

    socket =
      socket
      |> update(:grid_items, fn current_items ->
        Enum.map(current_items, fn item ->
          changed_item =
            Enum.find(items, fn changed ->
              changed["id"] == item.id or changed["id"] == "widget-#{item.uuid}"
            end)

          if changed_item do
            %{
              item
              | x: to_integer(changed_item["x"]),
                y: to_integer(changed_item["y"]),
                w: to_integer(changed_item["w"]),
                h: to_integer(changed_item["h"])
            }
          else
            item
          end
        end)
      end)

    {:noreply, socket}
  end

  def handle_event("remove_widget", %{"uuid" => uuid, "layout_uuid" => layout_uuid}, socket) do
    widget = Widget.get_widget(uuid)

    socket =
      if widget do
        Framework.System.remove_widget(uuid, layout_uuid)

        user = socket.assigns.phoenix_kit_current_user

        grid_items =
          Layout.layout_for(user, @page)
          |> Framework.Dashboard.Grid.from_layout()

        {:noreply,
         assign(socket,
           grid_items: grid_items,
           available: Framework.Schema.Widget.diff_widgets(grid_items, Widget.load_all_widgets())
         )}
      else
        {:noreply, socket}
      end
  end

  # Helper to persist grid layout to database
  defp persist_grid_layout(socket) do
    layout_uuid = socket.assigns.layout_uuid
    grid_items = socket.assigns.grid_items

    Enum.each(grid_items, fn item ->
      Framework.System.update_widget_layout(item.uuid, layout_uuid, %{
        x: item.x,
        y: item.y,
        w: item.w,
        h: item.h
      })
    end)

    socket
  end

  # Helper to safely convert values to integers
  defp to_integer(val) when is_integer(val), do: val
  defp to_integer(val) when is_binary(val), do: String.to_integer(val)
  defp to_integer(val), do: val

  @impl true
  def render(assigns) do
    ~H"""
    <FrameworkWeb.Layouts.dashboard {dashboard_assigns(assigns)}>
      <div class="flex max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 gap-6 items-start">
        
    <!-- MAIN -->
        <div class="flex-1 min-w-0">
          <.user_dashboard_header title={@page_title} />
          
    <!-- GRID -->
          <div
            id="grid_container"
            class="grid-stack"
            data-options={Jason.encode!(@grid_options)}
          >
            <%= for w <- @grid_items do %>
              <div
                id={"widget-#{w.uuid}"}
                class="grid-stack-item"
                data-uuid={w.widget.uuid}
                data-name={w.widget.name}
                gs-x={w.x || "auto"}
                gs-y={w.y || "auto"}
                gs-w={w.w}
                gs-h={w.h}
              >
                <div class="grid-stack-item-content">
                  <.dashboard_stack
                    item={w.widget}
                    user={assigns.phoenix_kit_current_user}
                  />
                </div>
              </div>
            <% end %>
          </div>
        </div>
        
    <!-- SIDEBAR -->
        <div
          :if={Enum.count(@available) > 0}
          id="widget_sidebar"
          phx-hook="Persist"
          data-key="sidebar:collapsed"
        >
          <div :if={!@show_sidebar} class="w-80 text-right">
            <button class="btn btn-xs btn-ghost" phx-click="toggle_sidebar">
              ☰
            </button>
          </div>

          <div :if={@show_sidebar} class="w-80">
            <div class="sticky top-4">
              <div class="card bg-base-100 shadow-md border border-base-300">
                <div class="card-body p-4">
                  <div class="flex justify-between mb-2">
                    <h3 class="font-semibold text-base">Available Widgets</h3>
                    <button class="btn btn-xs btn-ghost" phx-click="toggle_sidebar">→</button>
                  </div>

                  <div class="space-y-2 max-h-[500px] overflow-y-auto">
                    <%= for w <- @available do %>
                      <div class="p-2 rounded hover:bg-base-200 flex justify-between">
                        <div>
                          <div class="text-sm font-medium">{w.name}</div>
                          <div class="text-xs opacity-60">{w.description}</div>
                        </div>

                        <button
                          class="btn btn-xs btn-primary"
                          phx-click="grid:item_added"
                          phx-value-widget={w.uuid}
                          phx-value-layout={@layout_uuid}
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
    </FrameworkWeb.Layouts.dashboard>
    """
  end

  # ------------------------
  # Widget renderer
  # ------------------------

  defp dashboard_stack(assigns) do
    ~H"""
    <div class="card bg-base-100 shadow-sm border border-base-300 h-full">
      <div class="card-body p-3">
        <div class="flex items-center justify-between">
          <span class="font-semibold text-sm">
            {@item.name}
          </span>

          <button
            class="btn btn-xs btn-ghost"
            phx-click="remove_widget"
            phx-value-uuid={@item.uuid}
            phx-value-layout_uuid={@item.layout_uuid}
          >
            ×
          </button>
        </div>

        <div class="flex-1 overflow-auto">
          {@item.value.(@user)}
        </div>
      </div>
    </div>
    """
  end

  #  def handle_event("remove_widget", %{"uuid" => uuid, "layout_uuid" => layout_uuid}, socket) do
  #    widget = Widget.get_widget(uuid)
  #
  #    socket =
  #      if(widget) do
  #        Framework.System.remove_widget(uuid, layout_uuid)
  #
  #        user = socket.assigns.phoenix_kit_current_user
  #
  #        grid_items =
  #          Layout.layout_for(user, @page)
  #          |> Framework.Dashboard.Grid.from_layout()
  #
  #        {:noreply,
  #         assign(socket,
  #           grid_items: grid_items,
  #           available: Framework.Schema.Widget.diff_widgets(grid_items, Widget.load_all_widgets())
  #         )}
  #      else
  #        {:noreply, socket}
  #      end
  #  end
end
