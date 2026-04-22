defmodule Framework.System do
  @moduledoc """
  The System context.
  """

  import Ecto.Query, warn: false
  alias Framework.Repo

  def create_layout(user, name) do
    {:ok, data} =
      %Framework.Schema.Layout{}
      |> Framework.Schema.Layout.changeset(%{user_uuid: user.uuid, name: name})
      |> Repo.insert()

    Map.put(data, :widgets, [])
  end

  def add_widget(uuid, layout_uuid) do
    %Framework.Schema.Widget{}
    |> Framework.Schema.Widget.changeset(%{uuid: uuid, layout_uuid: layout_uuid})
    |> IO.inspect()
    |> Repo.insert()
  end

  def remove_widget(uuid, layout_uuid) do
    from(w in Framework.Schema.Widget,
      where: w.uuid == ^uuid and w.layout_uuid == ^layout_uuid
    )
    |> Repo.delete_all()
  end

  def widget_in_grid(uuid, layout_uuid) do
    Repo.get_by(Framework.Schema.Widget, uuid: uuid, layout_uuid: layout_uuid)
  end

  def update_widget_layout(_, _, _) do
    {:ok, []}
  end
end
