# lib/framework_web/components/sidebar.ex

defmodule FrameworkWeb.Components.Sidebar do
  use Phoenix.Component
  import FrameworkWeb.Components.MenuNode

  attr :menu, :list, required: true
  attr :open_sections, :map, required: true
  attr :current_path, :string, required: true

  def sidebar(assigns) do
    ~H"""
    <aside class="w-64 h-screen border-r bg-white p-3 space-y-1">
      <%= for item <- @menu do %>
        <.menu_node item={item} open={@open_sections} current_path={@current_path} />
      <% end %>
    </aside>
    """
  end
end