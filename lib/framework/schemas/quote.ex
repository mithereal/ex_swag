# lib/print_industry/schemas/quote.ex

defmodule PrintIndustry.Quote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quotes" do
    field :quote_number, :string
    field :customer_id, :id
    field :print_service_id, :id
    field :quantity, :integer
    field :estimated_price, :decimal
    field :material_cost, :decimal
    field :labor_cost, :decimal
    field :markup_percentage, :decimal
    field :valid_until, :utc_datetime
    field :status, :string
    field :notes, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(quote, attrs) do
    quote
    |> cast(attrs, [
      :quote_number,
      :customer_id,
      :print_service_id,
      :quantity,
      :estimated_price,
      :material_cost,
      :labor_cost,
      :markup_percentage,
      :valid_until,
      :status,
      :notes
    ])
    |> validate_required([:quote_number, :quantity])
    |> validate_inclusion(:status, ["pending", "accepted", "rejected", "expired"])
  end
end