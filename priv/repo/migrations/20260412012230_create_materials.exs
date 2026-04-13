# priv/repo/migrations/[timestamp]_create_materials.exs

defmodule FrameworkWeb.Repo.Migrations.CreateMaterials do
  use Ecto.Migration

  def change do
    create table(:materials) do
      add :name, :string, null: false
      add :category, :string, null: false  # paper, plastic, fabric, etc.
      add :weight, :string  # gsm or other units
      add :finish, :string  # matte, gloss, etc.
      add :cost_per_unit, :decimal
      add :supplier, :string
      add :specifications, :jsonb

      timestamps(type: :utc_datetime)
    end

    create index(:materials, [:category])
  end
end