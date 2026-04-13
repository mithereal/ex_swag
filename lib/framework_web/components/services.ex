defmodule FrameworkWeb.Components.Services do
  use Phoenix.Component
  use Gettext, backend: FrameworkWeb.Gettext

  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :rows, :list, required: true

  def services_table(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">
              Service Name
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">
              Type
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">
              Base Price
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">
              Turnaround
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">
              Status
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-700 uppercase">
              Actions
            </th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <%= for {_id, service} <- @rows do %>
            <tr class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {service.name}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                <span class="px-2 py-1 bg-blue-100 text-blue-800 rounded text-xs font-semibold">
                  {service.service_type}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                ${service.base_price}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                {service.turnaround_days} days
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <%= if service.is_active do %>
                  <span class="px-3 py-1 bg-green-100 text-green-800 rounded-full text-xs font-semibold">
                    Active
                  </span>
                <% else %>
                  <span class="px-3 py-1 bg-red-100 text-red-800 rounded-full text-xs font-semibold">
                    Inactive
                  </span>
                <% end %>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm space-x-2">
                <.link
                  navigate={"/print-services/#{service.id}"}
                  class="text-blue-600 hover:underline"
                >
                  View
                </.link>
                <.link
                  navigate={"/print-services/#{service.id}/edit"}
                  class="text-blue-600 hover:underline"
                >
                  Edit
                </.link>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  attr :service, :map, required: true
  attr :on_submit, :any, required: true

  def service_form(assigns) do
    ~H"""
    <form phx-submit={@on_submit} class="space-y-6">
      <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
        <div>
          <label class="block text-sm font-medium text-gray-700">Service Name</label>
          <input
            type="text"
            name="name"
            value={@service.name}
            placeholder="e.g., Offset Printing"
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Service Type</label>
          <select
            name="service_type"
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500"
          >
            <option value="">Select type</option>
            <option value="offset" selected={@service.service_type == "offset"}>
              Offset Printing
            </option>
            <option value="digital" selected={@service.service_type == "digital"}>
              Digital Printing
            </option>
            <option value="flexo" selected={@service.service_type == "flexo"}>Flexography</option>
            <option value="screen" selected={@service.service_type == "screen"}>
              Screen Printing
            </option>
            <option value="letterpress" selected={@service.service_type == "letterpress"}>
              Letterpress
            </option>
            <option value="large_format" selected={@service.service_type == "large_format"}>
              Large Format
            </option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Base Price</label>
          <input
            type="number"
            step="0.01"
            name="base_price"
            value={@service.base_price}
            placeholder="0.00"
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Unit</label>
          <select
            name="unit"
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500"
          >
            <option value="">Select unit</option>
            <option value="per_piece" selected={@service.unit == "per_piece"}>Per Piece</option>
            <option value="per_meter" selected={@service.unit == "per_meter"}>Per Meter</option>
            <option value="per_hour" selected={@service.unit == "per_hour"}>Per Hour</option>
            <option value="per_sheet" selected={@service.unit == "per_sheet"}>Per Sheet</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Turnaround Days</label>
          <input
            type="number"
            name="turnaround_days"
            value={@service.turnaround_days}
            min="1"
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Minimum Order Quantity</label>
          <input
            type="number"
            name="min_order_quantity"
            value={@service.min_order_quantity}
            min="1"
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500"
          />
        </div>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700">Description</label>
        <textarea
          name="description"
          rows="4"
          placeholder="Service description and details"
          class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500"
        ><%= @service.description %></textarea>
      </div>

      <div class="flex items-center">
        <input
          type="checkbox"
          name="is_active"
          checked={@service.is_active}
          class="h-4 w-4 text-blue-600 rounded"
        />
        <label class="ml-2 text-sm text-gray-700">Service is Active</label>
      </div>

      <div class="flex gap-4">
        <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
          Save Service
        </button>
        <.link
          navigate="/print-services"
          class="px-4 py-2 bg-gray-300 text-gray-700 rounded-md hover:bg-gray-400"
        >
          Cancel
        </.link>
      </div>
    </form>
    """
  end

  attr :order, :map, required: true
  attr :services, :list, required: true
  attr :materials, :list, required: true

  def order_form(assigns) do
    ~H"""
    <form class="space-y-6">
      <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
        <div>
          <label class="block text-sm font-medium text-gray-700">Order Number</label>
          <input
            type="text"
            name="order_number"
            value={@order.order_number}
            placeholder="PO-2024-001"
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md"
            readonly
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Print Service</label>
          <select
            name="print_service_id"
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md"
          >
            <option value="">Select service</option>
            <%= for service <- @services do %>
              <option value={service.id} selected={@order.print_service_id == service.id}>
                {service.name} - ${service.base_price} {service.unit}
              </option>
            <% end %>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Material</label>
          <select name="material_id" class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md">
            <option value="">Select material</option>
            <%= for material <- @materials do %>
              <option value={material.id} selected={@order.material_id == material.id}>
                {material.name}
              </option>
            <% end %>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Quantity</label>
          <input
            type="number"
            name="quantity"
            value={@order.quantity}
            min="1"
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Dimensions (W x H)</label>
          <input
            type="text"
            name="dimensions"
            value={@order.dimensions}
            placeholder="210x297mm"
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Number of Colors</label>
          <input
            type="number"
            name="colors"
            value={@order.colors}
            min="1"
            max="8"
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Status</label>
          <select name="status" class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md">
            <option value="pending" selected={@order.status == "pending"}>Pending</option>
            <option value="approved" selected={@order.status == "approved"}>Approved</option>
            <option value="in_production" selected={@order.status == "in_production"}>
              In Production
            </option>
            <option value="completed" selected={@order.status == "completed"}>Completed</option>
            <option value="shipped" selected={@order.status == "shipped"}>Shipped</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700">Delivery Date</label>
          <input
            type="datetime-local"
            name="delivery_date"
            value={@order.delivery_date}
            class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md"
          />
        </div>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700">Order Notes</label>
        <textarea
          name="notes"
          rows="4"
          placeholder="Special instructions, color matching, QC notes..."
          class="mt-1 w-full px-3 py-2 border border-gray-300 rounded-md"
        ><%= @order.notes %></textarea>
      </div>

      <div class="bg-blue-50 p-4 rounded-md">
        <p class="text-sm text-gray-700">
          <strong>Estimated Total:</strong> ${@order.total_price || "0.00"}
        </p>
      </div>

      <div class="flex gap-4">
        <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
          Save Order
        </button>
        <.link
          navigate="/print-services/orders"
          class="px-4 py-2 bg-gray-300 text-gray-700 rounded-md"
        >
          Cancel
        </.link>
      </div>
    </form>
    """
  end

  attr :quote, :map, required: true

  def quote_summary(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-6 space-y-4">
      <h3 class="text-lg font-semibold text-gray-900">Quote Summary</h3>

      <div class="border-t border-gray-200 pt-4 space-y-3">
        <div class="flex justify-between">
          <span class="text-gray-600">Quote #:</span>
          <span class="font-semibold">{@quote.quote_number}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-gray-600">Quantity:</span>
          <span class="font-semibold">{@quote.quantity}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-gray-600">Material Cost:</span>
          <span class="font-semibold">${@quote.material_cost || "0.00"}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-gray-600">Labor Cost:</span>
          <span class="font-semibold">${@quote.labor_cost || "0.00"}</span>
        </div>
        <div class="flex justify-between">
          <span class="text-gray-600">Markup ({@quote.markup_percentage}%):</span>
          <span class="font-semibold">
            ${Decimal.mult(
              Decimal.add(@quote.material_cost || 0, @quote.labor_cost || 0),
              Decimal.div(@quote.markup_percentage || 25, 100)
            )}
          </span>
        </div>
      </div>

      <div class="border-t border-gray-200 pt-4">
        <div class="flex justify-between items-center">
          <span class="text-lg font-semibold text-gray-900">Total:</span>
          <span class="text-2xl font-bold text-blue-600">
            ${@quote.estimated_price}
          </span>
        </div>
      </div>

      <div class="text-xs text-gray-500 text-right">
        Valid until: {@quote.valid_until}
      </div>
    </div>
    """
  end
end
