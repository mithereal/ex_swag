defmodule Framework.Repo.Migrations.CreateGridWidgets do
  use Ecto.Migration

  def change do
    create table(:grid_widgets, primary_key: false) do
      add :uuid, :binary_id, primary_key: false

      add :layout_uuid,
          references(:grid_layouts,
            column: :uuid,
            type: :binary_id,
            on_delete: :delete_all
          ),
          null: false

      add :type, {:array, :string}, default: ["chart", "text", "image", "table"]
      add :x, :integer, default: 0
      add :y, :integer, default: 0
      add :w, :integer, default: 2
      add :h, :integer, default: 2
      add :config, :map, default: %{}

      timestamps()
    end

    #  create index(:grid_widgets, [:grid_layout_uuid])
  end
end
