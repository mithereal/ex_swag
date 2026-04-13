# priv/repo/migrations/[timestamp]_create_orders.exs

defmodule FrameworkWeb.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :order_number, :string, null: false
      add :customer_id, references(:phoenix_kit_users, column: :uuid, type: :uuid)
      add :print_service_id, references(:print_services)
      add :material_id, references(:materials)
      add :quantity, :integer, null: false
      add :dimensions, :string  # width x height format
      add :colors, :integer  # number of colors
      add :finish, :string
      add :status, :string, default: "pending"  # pending, approved, in_production, completed, shipped
      add :order_date, :utc_datetime
      add :delivery_date, :utc_datetime
      add :total_price, :decimal
      add :notes, :text
      add :custom_specifications, :jsonb

      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:status])
   # create index(:orders, [:customer_id])
    create index(:orders, [:order_number])
  end
end