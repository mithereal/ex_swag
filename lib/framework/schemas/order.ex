# lib/print_industry/schemas/order.ex

defmodule Framework.Schema.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :order_number, :string
    field :customer_id, :id
    field :print_service_id, :id
    field :material_id, :id
    field :quantity, :integer
    field :dimensions, :string
    field :colors, :integer
    field :finish, :string
    field :status, :string
    field :order_date, :utc_datetime
    field :delivery_date, :utc_datetime
    field :total_price, :decimal
    field :notes, :string
    field :custom_specifications, :map

    timestamps(type: :utc_datetime)
  end

  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :order_number,
      :customer_id,
      :print_service_id,
      :material_id,
      :quantity,
      :dimensions,
      :colors,
      :finish,
      :status,
      :order_date,
      :delivery_date,
      :total_price,
      :notes,
      :custom_specifications
    ])
    |> validate_required([:order_number, :quantity, :customer_id, :print_service_id])
    |> validate_number(:quantity, greater_than: 0)
    |> validate_inclusion(:status, [
      "pending",
      "approved",
      "in_production",
      "completed",
      "shipped"
    ])
    |> unique_constraint(:order_number)
  end
end
