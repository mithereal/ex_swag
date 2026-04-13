# lib/framework_web/components/dashboard_card.ex

defmodule FrameworkWeb.Components.Dashboard do
  use Phoenix.Component

  attr :item, :map, required: true

  def dashboard_card(assigns) do
    ~H"""
    <a href={@item.path} class="block p-4 border rounded hover:shadow">
      <div class="text-sm text-gray-500">{@item.title}</div>
      <div class="text-lg font-bold">{@item.value}</div>
    </a>
    """
  end
end
