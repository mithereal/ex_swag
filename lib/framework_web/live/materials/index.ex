# lib/FrameworkWeb_web/live/materials_live/index.ex

defmodule FrameworkWeb.MaterialsLive.Index do
  use FrameworkWeb, :live_view

  alias Framework

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Materials")
     |> stream(:materials, Framework.list_materials())}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <.header>
        Print Materials
        <:subtitle>View and manage customer materials</:subtitle>
        <:actions>
          <.link navigate={~p"/materials/new"} class="btn btn-primary">
            New Order
          </.link>
        </:actions>
      </.header>

      <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Order #</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Quantity
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200">
            <%= for {_id, order} <- @streams.materials do %>
              <tr>
                <td class="px-6 py-4">{order.order_number}</td>
                <td class="px-6 py-4">
                  <span
                    class="px-2 py-1 rounded-full text-xs font-semibold"
                    style={"background-color: #{status_color(order.status)}"}
                  >
                    {order.status}
                  </span>
                </td>
                <td class="px-6 py-4">{order.quantity}</td>
                <td class="px-6 py-4">${order.total_price}</td>
                <td class="px-6 py-4">
                  <.link navigate={~p"/materials/#{order.id}"} class="text-blue-600 hover:underline">
                    View
                  </.link>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp status_color("pending"), do: "#FEE2E2"
  defp status_color("approved"), do: "#D1FAE5"
  defp status_color("in_production"), do: "#DBEAFE"
  defp status_color("completed"), do: "#C7D2FE"
  defp status_color("shipped"), do: "#86EFAC"
  defp status_color(_), do: "#E5E7EB"
end
