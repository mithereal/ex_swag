defmodule Framework.Repo.Migrations.CreateGridLayouts do
  use Ecto.Migration

  @primary_key {:uuid, :binary_id, autogenerate: true}
  @foreign_key {:uuid, :binary_id}

  def change do
    create table(:grid_layouts, primary_key: false) do
      add :uuid, :binary_id, primary_key: true

      add :user_uuid,
          references(:phoenix_kit_users,
            column: :uuid,
            type: :binary_id,
            on_delete: :delete_all
          )

      add :name, :string, default: "My Grid"
      add :sidebar_open, :boolean, default: true
      add :grid_config, :map, default: %{}

      timestamps()
    end
  end
end
