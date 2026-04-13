# lib/global_erp/inventory/live/inventory_live.ex

defmodule FrameworkWeb.Inventory.Live.InventoryLive do
  use FrameworkWeb, :live_view

  alias Framework.Inventory

  def mount(_, _, socket) do
    {:ok,
      assign(socket,
        items: load_items(),
        page_title: "Inventory"
      )}
  end

  defp load_items do
    [
      %{name: "Shirt", stock: 42},
      %{name: "Hat", stock: 15},
      %{name: "Sticker", stock: 200}
    ]
  end

  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-xl font-bold mb-4">Inventory</h1>

      <table class="w-full border">
        <thead>
          <tr class="bg-gray-100">
            <th class="p-2 text-left">Item</th>
            <th class="p-2 text-left">Stock</th>
          </tr>
        </thead>

        <tbody>
          <%= for item <- @items do %>
            <tr class="border-t">
              <td class="p-2"><%= item.name %></td>
              <td class="p-2"><%= item.stock %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end