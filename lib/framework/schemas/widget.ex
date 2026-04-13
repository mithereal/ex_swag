defmodule Framework.Schema.Widget do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:uuid, UUIDv7, autogenerate: true}
  @foreign_key_type UUIDv7
  schema "phoenix_kit_dashboard_layout_widgets" do
    field :widget_type, :string
    field :x, :integer, default: 0
    field :y, :integer, default: 0
    field :w, :integer, default: 2
    field :h, :integer, default: 2
    field :config, :map, default: %{}

    belongs_to :widget_layout, Framework.Schema.Layout

    timestamps()
  end

  def changeset(widget, attrs) do
    widget
    |> cast(attrs, [:widget_type, :x, :y, :w, :h, :config, :uuid])
    |> validate_required([:widget_type])
  end
end
