# lib/print_industry/schemas/material.ex

defmodule Framework.Schema.Material do
  use Ecto.Schema
  import Ecto.Changeset

  schema "materials" do
    field :name, :string
    field :category, :string
    field :weight, :string
    field :finish, :string
    field :cost_per_unit, :decimal
    field :supplier, :string
    field :specifications, :map

    timestamps(type: :utc_datetime)
  end

  def changeset(material, attrs) do
    material
    |> cast(attrs, [
      :name,
      :category,
      :weight,
      :finish,
      :cost_per_unit,
      :supplier,
      :specifications
    ])
    |> validate_required([:name, :category])
    |> validate_number(:cost_per_unit, greater_than: 0)
  end
end
