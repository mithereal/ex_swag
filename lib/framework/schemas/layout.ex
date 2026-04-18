defmodule Framework.Schema.Layout do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:uuid, UUIDv7, autogenerate: true}
  @foreign_key_type UUIDv7
  schema "phoenix_kit_dashboard_widget_layouts" do
    field :name, :string, default: "My Grid"
    field :sidebar_open, :boolean, default: true
    field :widgets, :map, default: %{}
    field :grid_config, :map, default: %{}

    belongs_to :user, PhoenixKit.Users.Auth.User,
      foreign_key: :user_uuid,
      references: :uuid,
      type: UUIDv7

    has_many :layout_widgets, Framework.Schema.Widget

    timestamps()
  end

  defp repo, do: PhoenixKit.RepoHelper.repo()

  def changeset(grid_layout, attrs) do
    grid_layout
    |> cast(attrs, [:name, :sidebar_open, :widgets, :grid_config, :user_uuid])
    |> validate_required([:user_uuid])
  end

  def widgets_for(user) do
    try do
      repo().get_by!(Framework.Schema.Layout, uuid: user.uuid)
    rescue
      _ -> []
    end
  end
end
