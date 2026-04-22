# lib/print_industry/schemas/print_service.ex

defmodule Framework.Schema.PrintService do
  use Ecto.Schema
  import Ecto.Changeset

  schema "print_services" do
    field :name, :string
    field :description, :string
    field :service_type, :string
    field :base_price, :decimal
    field :unit, :string
    field :turnaround_days, :integer
    field :min_order_quantity, :integer
    field :specifications, :map
    field :is_active, :boolean, default: true
    field :created_by, :id

    timestamps(type: :utc_datetime)
  end

  def changeset(service, attrs) do
    service
    |> cast(attrs, [
      :name,
      :description,
      :service_type,
      :base_price,
      :unit,
      :turnaround_days,
      :min_order_quantity,
      :specifications,
      :is_active,
      :created_by
    ])
    |> validate_required([:name, :service_type, :base_price, :unit])
    |> validate_number(:base_price, greater_than: 0)
    |> validate_number(:turnaround_days, greater_than_or_equal_to: 1)
    |> validate_number(:min_order_quantity, greater_than_or_equal_to: 1)
  end
end
