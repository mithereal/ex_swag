# priv/repo/migrations/[timestamp]_create_quotes.exs

defmodule FrameworkWeb.Repo.Migrations.CreateQuotes do
  use Ecto.Migration

  def change do
    create table(:quotes) do
      add :quote_number, :string, null: false
      add :customer_id, references(:phoenix_kit_users, column: :uuid, type: :uuid)
      add :print_service_id, references(:print_services)
      add :quantity, :integer, null: false
      add :estimated_price, :decimal
      add :material_cost, :decimal
      add :labor_cost, :decimal
      add :markup_percentage, :decimal, default: 25.0
      add :valid_until, :utc_datetime
      add :status, :string, default: "pending"  # pending, accepted, rejected, expired
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:quotes, [:status])
  #  create index(:quotes, [:customer_id])
    create index(:quotes, [:quote_number])
  end
end