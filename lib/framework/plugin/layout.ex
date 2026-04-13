defmodule Framework.Plugin.Layout do
  import Ecto.Query
  alias Framework.Repo
  alias Framework.Accounts.DashboardLayout
  alias Framework.Plugin.Registry

  def widgets_for(user) do
    available =
      Registry.widgets(user)
      |> Map.new(&{to_string(&1.id), &1})

    Repo.all(from l in DashboardLayout, where: l.user_id == ^user.id)
    |> Enum.map(fn l ->
      widget = Map.get(available, l.widget_id)

      if widget do
        Map.put(widget, :layout, %{
          x: l.x, y: l.y, w: l.w, h: l.h
        })
      end
    end)
    |> Enum.filter(& &1)
  end

  def available_widgets(user) do
    active =
      widgets_for(user)
      |> Map.new(&{to_string(&1.id), &1})

    Registry.widgets(user)
    |> Enum.reject(fn w -> Map.has_key?(active, to_string(w.id)) end)
  end

  def add_widget(user, id) do
    Repo.insert!(
      %DashboardLayout{
        user_id: user.id,
        widget_id: id,
        x: 0, y: 0, w: 3, h: 2
      },
      on_conflict: :nothing
    )
  end

  def remove_widget(user, id) do
    from(l in DashboardLayout,
      where: l.user_id == ^user.id and l.widget_id == ^id
    )
    |> Repo.delete_all()
  end

  def save_grid(user, items) do
    Enum.each(items, fn i ->
      Repo.insert!(
        %DashboardLayout{
          user_id: user.id,
          widget_id: i["id"],
          x: i["x"],
          y: i["y"],
          w: i["w"],
          h: i["h"]
        },
        on_conflict: [
          set: [x: i["x"], y: i["y"], w: i["w"], h: i["h"]]
        ],
        conflict_target: [:user_id, :widget_id]
      )
    end)
  end

  def remove_widget(user, widget_id) do
    from(l in Framework.Accounts.DashboardLayout,
      where: l.user_id == ^user.id and l.widget_id == ^widget_id
    )
    |> Framework.Repo.delete_all()
  end

  def add_widget(user, widget_id) do
    Repo.insert!(
      %DashboardLayout{
        user_id: user.id,
        widget_id: widget_id,
        x: 0,
        y: 0,
        w: 3,
        h: 2
      },
      on_conflict: :nothing
    )
  end

  def available_widgets(user) do
    all =
      Registry.widgets(user)
      |> Map.new(&{to_string(&1.id), &1})

    active =
      widgets_for(user)
      |> Map.new(&{to_string(&1.id), &1})

    all
    |> Enum.reject(fn {id, _} -> Map.has_key?(active, id) end)
    |> Enum.map(fn {_id, w} -> w end)
  end
end