defmodule FrameworkWeb.Components.DashboardCard do
  use FrameworkWeb, :html

  attr :item, :map, required: true

  def dashboard_card(assigns) do
    ~H"""
    <div class="p-4 border rounded bg-white h-full">
      <div class="text-sm text-gray-500">{@item.title}</div>
      <div class="text-xl font-bold">
        {render_value(@item.value)}
      </div>
    </div>
    """
  end

  defp render_value(widget) do
    cond do
      Map.has_key?(widget, :live_value) -> widget.live_value
      is_function(widget.value, 1) -> widget.value.(nil)
      true -> widget.value
    end
  end

  defp render_value(fun) when is_function(fun, 1), do: fun.(nil)
  defp render_value(val), do: val
end
