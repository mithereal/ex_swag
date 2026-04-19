defmodule Framework.Schema.Layout do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:uuid, UUIDv7, autogenerate: true}
  @foreign_key_type UUIDv7
  schema "grid_layouts" do
    field :name, :string, default: "My Grid"
    field :sidebar_open, :boolean, default: true
    field :grid_config, :map, default: %{}

    belongs_to :user, PhoenixKit.Users.Auth.User,
      foreign_key: :user_uuid,
      references: :uuid,
      type: UUIDv7

    has_many :widgets, Framework.Schema.Widget

    timestamps()
  end

  defp repo, do: PhoenixKit.RepoHelper.repo()

  def changeset(grid_layout, attrs) do
    grid_layout
    |> cast(attrs, [:name, :sidebar_open, :grid_config, :user_uuid])
    |> validate_required([:user_uuid])
  end

  def layouts_for(user) do
    try do
      repo().get_all!(Framework.Schema.Layout, user: user)
    rescue
      _ -> []
    end
  end

  import Ecto.Query

  def layout_for(user, name) do
    try do
      Framework.Schema.Layout
      |> where(user_uuid: ^user.uuid)
      |> preload(:widgets)
      |> repo().one()
    rescue
      e ->
        IO.inspect(e, label: "e")
        nil
    end
  end
end
