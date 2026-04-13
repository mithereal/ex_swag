# priv/repo/migrations/[timestamp]_create_print_services.exs

defmodule FrameworkWeb.Repo.Migrations.CreatePrintServices do
  use Ecto.Migration

  def change do
    create table(:print_services) do
      add :name, :string, null: false
      add :description, :text
      add :service_type, :string, null: false  # offset, digital, flexo, screen, etc.
      add :base_price, :decimal, null: false
      add :unit, :string, null: false  # per_piece, per_meter, per_hour, etc.
      add :turnaround_days, :integer
      add :min_order_quantity, :integer
      add :specifications, :jsonb  # Store technical specs as JSON
      add :is_active, :boolean, default: true
      add :created_by, references(:phoenix_kit_users, column: :uuid, type: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:print_services, [:service_type])
    create index(:print_services, [:is_active])
  end
end