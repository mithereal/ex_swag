defmodule FrameworkWeb.Dashboard.User do
  @moduledoc """
  User dashboard LiveView for user.
  """

  use FrameworkWeb, :live_view

  alias PhoenixKit.Dashboard.Widget
  alias Framework.Schema.Layout

  import PhoenixKitWeb.LayoutHelpers, only: [dashboard_assigns: 1]

  import PhoenixKitWeb.Components.Core.UserDashboardHeader,
    only: [user_dashboard_header: 1]

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.phoenix_kit_current_user

    socket =
      assign(socket,
        show_sidebar: true
      )

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

  def handle_event("toggle_sidebar", _, socket) do
    new_state = !socket.assigns.show_sidebar

    token = :todo

    # push_redirect(socket, to: "/persistence/sidebar?token=#{token}&state=#{new_state}")

    socket =
      socket
      |> assign(:show_sidebar, new_state)

    {:noreply, socket}
  end

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
          if item.id == id, do: %{item | w: w, h: h, x: x, y: y}, else: item
        end)
      end)
      |> assign(:last_event, {:item_resized, id, "#{w}×#{h} at (#{x}, #{y})"})

    {:noreply, socket}
  end

  def handle_event("grid:item_moved", %{"id" => id, "x" => x, "y" => y}, socket) do
    IO.inspect({:moved, id, x, y})

    socket =
      socket
      |> update(:grid_items, fn items ->
        Enum.map(items, fn item ->
          if item.id == id, do: %{item | x: x, y: y}, else: item
        end)
      end)
      |> assign(:last_event, {:item_moved, id, "(#{x}, #{y})"})

    {:noreply, socket}
  end

  ## fixme:: name
  def handle_event("grid:item_added", %{"widget" => widget} = params, socket) do
    IO.inspect({:added, params})

    socket =
      socket
      |> update(:grid_items, fn items ->
        items ++
          [
            %{
              uuid: widget,
              x: params["x"] || 0,
              y: params["y"] || 0,
              w: params["w"] || 2,
              h: params["h"] || 2,
              name: params["name"] || "New Item"
            }
          ]
      end)
      |> assign(:last_event, {:item_added, widget})

    {:noreply, socket}
  end

  def handle_event("grid:item_removed", %{"id" => id}, socket) do
    IO.inspect({:removed, id})

    socket =
      socket
      |> update(:grid_items, fn items ->
        Enum.reject(items, fn item -> item.id == id end)
      end)
      |> assign(:last_event, {:item_removed, id})

    {:noreply, socket}
  end

  def handle_event("grid:changed", %{"items" => items}, socket) do
    IO.inspect({:changed, items})
    {:noreply, assign(socket, :last_event, {:grid_changed, Enum.count(items), "items"})}
  end

  def handle_event("grid:layout_requested", %{"layout" => layout}, socket) do
    IO.inspect({:layout, layout})
    {:noreply, assign(socket, :current_layout, layout)}
  end

  def handle_event("grid:item_double_clicked", %{"id" => id}, socket) do
    IO.inspect({:double_clicked, id})
    {:noreply, assign(socket, :last_event, {:double_clicked, id})}
  end

  def handle_event("grid:resize_start", %{"id" => id}, socket) do
    IO.inspect({:resize_start, id})
    {:noreply, socket}
  end

  def handle_event("grid:item_locked", %{"id" => id}, socket) do
    IO.inspect({:item_locked, id})
    {:noreply, assign(socket, :last_event, {:item_locked, id})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <PhoenixKitWeb.Layouts.dashboard {dashboard_assigns(assigns)}>
      <div class="flex max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 gap-6">
        
    <!-- MAIN CONTENT -->
        <div class="flex-1 min-w-0">
          <.user_dashboard_header title={@page_title} />
          
    <!-- GRID -->
          <div
            id="grid_container"
            class="grid-stack mt-4"
            data-options={Jason.encode!(@grid_options)}
          >
            <%= for w <- @widgets do %>
              <div
                id={"widget-#{w.uuid}"}
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
          <div
            :if={!@show_sidebar}
            class={[
              "w-80 shrink-0 transition-all duration-300  text-right",
              @show_sidebar && "translate-x-0",
              !@show_sidebar && "translate-x-0 lg:translate-x-0"
            ]}
          >
            <button class="btn btn-xs btn-ghost" phx-click="toggle_sidebar">
              ☰
            </button>
          </div>
          <!-- RIGHT GUTTER -->
          <div
            :if={@show_sidebar}
            class={[
              "w-80 shrink-0 transition-all duration-300",
              @show_sidebar && "translate-x-0",
              !@show_sidebar && "translate-x-0 lg:translate-x-0"
            ]}
          >
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
                            {w.name}
                          </div>
                          <div class="text-xs opacity-60">
                            {w.description}
                          </div>
                        </div>

                        <button
                          class="btn btn-xs btn-primary"
                          phx-click="grid:item_added"
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
            {@item.title}
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
          {@item.description}
        </div>
      </div>
    </div>
    """
  end

  defp parse_int(value) when is_integer(value), do: value

  defp parse_int(value, default \\ 2) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> default
    end
  end

  def handle_event("remove_widget", %{"uuid" => uuid}, socket) do
    Layout.remove_widget(socket.assigns.phoenix_kit_current_user, uuid)

    {:noreply,
     assign(socket,
       widgets: Layout.widgets_for(socket.assigns.current_user),
       available: Widget.load_all_widgets(socket.assigns.current_user)
     )}
  end

  #
  #  def handle_event("save_grid", %{"items" => items}, socket) do
  #    layouts =
  #      Enum.map(items, fn item ->
  #        %{
  #          user_uuid: socket.assigns.phoenix_kit_current_user.uuid,
  #          uuid: item["uuid"],
  #          x: parse_int(item["x"]),
  #          y: parse_int(item["y"]),
  #          w: parse_int(item["w"], 3),
  #          h: parse_int(item["h"], 2),
  #          updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
  #        }
  #      end)
  #
  #    case Layout.save_grid(socket.assigns.phoenix_kit_current_user, items) do
  #      :ok ->
  #        {:noreply, socket}
  #
  #      {:error, _reason} ->
  #        {:noreply, put_flash(socket, :error, "Failed to save layout")}
  #    end
  #
  #    {:noreply, socket}
  #  end
end
