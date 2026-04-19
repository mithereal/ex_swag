defmodule Framework.Schema.Widget do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key false
  schema "grid_widgets" do
    field :uuid, UUIDv7
    field :config, :map, default: %{}

    belongs_to :layout, Framework.Schema.Layout,
      foreign_key: :layout_uuid,
      references: :uuid,
      type: UUIDv7

    field :x, :integer, default: 0
    field :y, :integer, default: 0
    field :w, :integer, default: 2
    field :h, :integer, default: 2

    timestamps()
  end

  def changeset(widget, attrs) do
    widget
    |> cast(attrs, [:uuid, :x, :y, :w, :h, :config, :layout_uuid])
    |> validate_required([:layout_uuid])
  end

  import Ecto.Query

  def layout_for(user, name) do
    try do
      Framework.Schema.Layout
      |> where(user_uuid: ^user.uuid)
      |> preload(:widgets)
      |> Framework.Repo.one()
    rescue
      e ->
        IO.inspect(e, label: "e")
        nil
    end
  end

  @doc """
  Compares two widget lists.

  Returns:
    {added, removed, unchanged}

  - added: in `new_list` but not in `old_list`
  - removed: in `old_list` but not in `new_list`
  - unchanged: present in both (matched by uuid)
  """
  def diff_widget_list(old_list, new_list) do
    old_by_id = map_by_uuid(old_list)
    new_by_id = map_by_uuid(new_list)

    old_ids = MapSet.new(Map.keys(old_by_id))
    new_ids = MapSet.new(Map.keys(new_by_id))

    added_ids = MapSet.difference(new_ids, old_ids)
    removed_ids = MapSet.difference(old_ids, new_ids)
    unchanged_ids = MapSet.intersection(old_ids, new_ids)

    added = Enum.map(added_ids, &Map.fetch!(new_by_id, &1))
    removed = Enum.map(removed_ids, &Map.fetch!(old_by_id, &1))
    unchanged = Enum.map(unchanged_ids, &Map.fetch!(new_by_id, &1))

    {added, removed, unchanged}
  end

  def diff_widgets(first_list, second_list) do
    first_uuids =
      first_list
      |> Enum.map(& &1.uuid)
      |> MapSet.new()

    Enum.reject(second_list, fn w ->
      MapSet.member?(first_uuids, w.uuid)
    end)
  end

  defp map_by_uuid(list) do
    Map.new(list, fn item -> {item.uuid, item} end)
  end
end
