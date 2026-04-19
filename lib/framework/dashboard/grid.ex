defmodule Framework.Dashboard.Grid do
  import Ecto.Query

  alias Framework.Schema.Layout
  alias Framework.Schema.Widget

  defp repo, do: PhoenixKit.RepoHelper.repo()

  def get_or_create_layout(user_uuid, name) do
    case repo().get_by(Layout, user_uuid: user_uuid, name: name) do
      nil ->
        {:ok, layout} =
          %Layout{}
          |> Layout.changeset(%{user_uuid: user_uuid, name: name})
          |> repo().insert()

        layout

      layout ->
        layout
    end
  end

  def from_layout(nil) do
    []
  end

  def from_layout(layout) do
    layout.widgets
    |> Enum.map(fn x ->
      widget =
        PhoenixKit.Dashboard.Widget.get_widget(x.uuid)
        |> Map.put(:layout_uuid, layout.uuid)

      Map.put(x, :widget, widget)
    end)
  end

  def update_sidebar(user_uuid, sidebar_open) do
    layout = get_or_create_layout(user_uuid, "dashboard")
    Layout.changeset(layout, %{sidebar_open: sidebar_open}) |> repo().update()
  end

  def upsert_widget(uuid, layout_uuid, %{x: x, y: y, w: w, h: h} = attrs) do
    case repo().get_by(Widget, layout_uuid: layout_uuid, uuid: uuid) do
      nil ->
        %Widget{}
        |> Widget.changeset(%{
          layout_uuid: layout_uuid,
          type: attrs[:type] || "default",
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

  def batch_update_widgets(layout_uuid, widgets) do
    Enum.each(widgets, fn %{uuid: uuid, x: x, y: y, w: w, h: h} ->
      case repo().get(Widget, uuid) do
        nil ->
          :ok

        widget ->
          Widget.changeset(widget, %{x: x, y: y, w: w, h: h, layout_uuid: layout_uuid})
          |> repo().update()
      end
    end)
  end
end
