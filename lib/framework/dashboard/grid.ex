defmodule PhoenixKit.Dashboard.Grid do
  import Ecto.Query

  alias Framework.Schema.Layout
  alias Framework.Schema.Widget

  defp repo, do: PhoenixKit.RepoHelper.repo()

  def get_or_create_layout(user_uuid) do
    case repo().get_by(Layout, user_uuid: user_uuid) do
      nil ->
        {:ok, layout} =
          %Layout{}
          |> Layout.changeset(%{user_uuid: user_uuid})
          |> repo().insert()

        layout

      layout ->
        layout
    end
  end

  def load_layout(user_uuid) do
    Layout
    |> where(user_uuid: ^user_uuid)
    |> preload(:grid_widgets)
    |> repo().one()
  end

  def update_sidebar(user_uuid, sidebar_open) do
    layout = get_or_create_layout(user_uuid)
    Layout.changeset(layout, %{sidebar_open: sidebar_open}) |> repo().update()
  end

  def upsert_widget(grid_layout_uuid, id, %{x: x, y: y, w: w, h: h} = attrs) do
    case repo().get_by(Widget, grid_layout_uuid: grid_layout_uuid, id: id) do
      nil ->
        %Widget{}
        |> Widget.changeset(%{
          grid_layout_uuid: grid_layout_uuid,
          widget_type: attrs[:widget_type] || "default",
          x: x,
          y: y,
          w: w,
          h: h,
          config: attrs[:config] || %{}
        })
        |> repo().insert()

      widget ->
        Widget.changeset(widget, %{x: x, y: y, w: w, h: h})
        |> repo().update()
    end
  end

  def delete_widget(id) do
    repo().get!(Widget, id) |> repo().delete()
  end

  def batch_update_widgets(grid_layout_uuid, widgets) do
    Enum.each(widgets, fn %{id: id, x: x, y: y, w: w, h: h} ->
      case repo().get(Widget, id) do
        nil -> :ok
        widget -> Widget.changeset(widget, %{x: x, y: y, w: w, h: h}) |> repo().update()
      end
    end)
  end
end
