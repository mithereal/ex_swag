# lib/framework_web/components/menu_node.ex

defmodule FrameworkWeb.Components.MenuNode do
  use Phoenix.Component

  attr :item, :map, required: true
  attr :open, :map, required: true
  attr :current_path, :string, required: true

  def menu_node(assigns) do
    ~H"""
    <div>

      <%= if Map.has_key?(@item, :children) do %>

        <button
          phx-click="toggle"
          phx-value-id={@item.id}
          class={[
            "w-full flex justify-between p-2 rounded",
            parent_active?(@item, @current_path) && "bg-gray-200 font-semibold"
          ]}
        >
          <%= @item.label %>
          <span>▸</span>
        </button>

        <%= if MapSet.member?(@open, @item.id) do %>
          <div class="ml-4 border-l pl-2">
            <%= for child <- @item.children do %>
              <.menu_node item={child} open={@open} current_path={@current_path} />
            <% end %>
          </div>
        <% end %>

      <% else %>

        <a
          href={@item.path}
          class={[
            "block p-2 rounded",
            active?(@current_path, @item.path) && "bg-gray-200 font-semibold"
          ]}
        >
          <%= @item.label %>
        </a>

      <% end %>

    </div>
    """
  end

  defp active?(current, path) do
    String.trim_trailing(current || "", "/") ==
      String.trim_trailing(path || "", "/")
  end

  defp parent_active?(item, current_path) do
    get_paths(item)
    |> Enum.any?(&active?(current_path, &1))
  end

  defp get_paths(%{children: children}) do
    Enum.flat_map(children, &get_paths/1)
  end

  defp get_paths(%{path: path}), do: [path]
  defp get_paths(_), do: []
end