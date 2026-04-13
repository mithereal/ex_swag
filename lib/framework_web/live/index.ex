defmodule FrameworkWeb.DashboardLive do
  use FrameworkWeb, :live_view

  alias Framework.Plugin.Layout

  def mount(_, _, socket) do
    user = socket.assigns.phoenix_kit_current_user

    if connected?(socket) do
      Phoenix.PubSub.subscribe(
        FrameworkWeb.PubSub,
        Framework.DashboardPubSub.topic(user.id)
      )
    end

    {:ok,
      assign(socket,
        widgets: Layout.widgets_for(user),
        available: Layout.available_widgets(user),
        show_modal: false,
        selected: MapSet.new()
      )}
  end

  def handle_info({:widget_update, widget_id, value}, socket) do
    widgets =
      Enum.map(socket.assigns.widgets, fn w ->
        if to_string(w.id) == to_string(widget_id) do
          Map.put(w, :live_value, value)
        else
          w
        end
      end)

    {:noreply, assign(socket, widgets: widgets)}
  end

  # OPEN MODAL
  def handle_event("open_modal", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  # CLOSE MODAL
  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false, selected: [])}
  end

  # TOGGLE SELECTION
  def handle_event("toggle", %{"id" => id}, socket) do
    selected =
      if id in socket.assigns.selected do
        List.delete(socket.assigns.selected, id)
      else
        [id | socket.assigns.selected]
      end

    {:noreply, assign(socket, selected: selected)}
  end

  # ADD SELECTED
  def handle_event("add_selected", _, socket) do
    user = socket.assigns.current_user

    Enum.each(socket.assigns.selected, fn id ->
      Layout.add_widget(user, id)
    end)

    {:noreply,
      assign(socket,
        widgets: Layout.widgets_for(user),
        available: Layout.available_widgets(user),
        show_modal: false,
        selected: []
      )}
  end

  # DELETE (right click)
  def handle_event("remove", %{"id" => id}, socket) do
    Layout.remove_widget(socket.assigns.current_user, id)

    {:noreply,
      assign(socket,
        widgets: Layout.widgets_for(socket.assigns.current_user)
      )}
  end

  # SAVE GRID
  def handle_event("save_grid", %{"items" => items}, socket) do
    Layout.save_grid(socket.assigns.current_user, items)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6">

      <!-- BUTTON -->
 <button
    phx-click="open_widget_modal"
    class="px-3 py-2 bg-blue-600 text-white rounded"
    >
    Add Widgets
    </button>

    <%= if @show_modal do %>
    <div class="fixed inset-0 bg-black/40 flex items-center justify-center">

    <div class="bg-white w-[600px] p-4 rounded">

      <h2 class="font-bold mb-4">Select Widgets</h2>

      <div class="space-y-2 max-h-[400px] overflow-auto">
        <%= for w <- @available do %>
          <label class="flex justify-between border p-2 rounded">

            <span><%= w.title %></span>

            <input
              type="checkbox"
              phx-click="toggle_widget"
              phx-value-id={w.id}
              checked={MapSet.member?(@selected, w.id)}
            />

          </label>
        <% end %>
      </div>

      <div class="flex justify-end gap-2 mt-4">
        <button phx-click="close_widget_modal" class="px-3 py-1 border">
          Cancel
        </button>

        <button phx-click="add_widgets" class="px-3 py-1 bg-green-600 text-white">
          OK
        </button>
      </div>

    </div>
    </div>
    <% end %>

      <!-- GRID -->
      <div id="grid_container"  class="grid-stack mt-4" phx-hook="Grid">
        <%= for w <- @widgets do %>
          <div id="grid"
            class="grid-stack-item"
            data-id={w.id}
            phx-hook="ContextMenu"
            gs-x={w.layout.x}
            gs-y={w.layout.y}
            gs-w={w.layout.w}
            gs-h={w.layout.h}
            phx-hook="ContextMenu"
          >
            <div class="grid-stack-item-content">
              <.dashboard_card item={w} />
            </div>
          </div>
        <% end %>
      </div>

      <!-- MODAL -->
      <%= if @show_modal do %>
        <div class="fixed inset-0 bg-black/40 flex items-center justify-center">

          <div class="bg-white w-[600px] p-4 rounded">

            <h2 class="font-bold mb-3">Widgets</h2>

            <div class="space-y-2 max-h-[400px] overflow-auto">
              <%= for w <- @available do %>
                <label class="flex justify-between border p-2 rounded">
                  <span><%= w.title %></span>

                  <input
                    type="checkbox"
                    phx-click="toggle"
                    phx-value-id={w.id}
                    checked={w.id in @selected}
                  />
                </label>
              <% end %>
            </div>

            <div class="flex justify-end gap-2 mt-4">
              <button phx-click="close_modal" class="px-3 py-1 border">Cancel</button>
              <button phx-click="add_selected" class="px-3 py-1 bg-green-600 text-white">
                Add
              </button>
            </div>

          </div>
        </div>
      <% end %>

    </div>
    """
  end

  def handle_event("remove_widget", %{"id" => id}, socket) do
    user = socket.assigns.current_user

    Framework.Plugin.Layout.remove_widget(user, id)

    {:noreply,
      assign(socket,
        widgets: Framework.Plugin.Layout.widgets_for(user)
      )}
  end
  def handle_event("open_widget_modal", _, socket) do
    {:noreply, assign(socket, show_modal: true)}
  end

  def handle_event("close_widget_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false, selected: MapSet.new())}
  end

  def handle_event("toggle_widget", %{"id" => id}, socket) do
    selected =
      if MapSet.member?(socket.assigns.selected, id) do
        MapSet.delete(socket.assigns.selected, id)
      else
        MapSet.put(socket.assigns.selected, id)
      end

    {:noreply, assign(socket, selected: selected)}
  end

  def handle_event("add_widgets", _, socket) do
    user = socket.assigns.current_user

    Enum.each(socket.assigns.selected, fn id ->
      Layout.add_widget(user, id)
    end)

    {:noreply,
      assign(socket,
        widgets: Layout.widgets_for(user),
        available: Layout.available_widgets(user),
        show_modal: false,
        selected: MapSet.new()
      )}
  end

end