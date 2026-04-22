defmodule Framework.Services.Order do
  @moduledoc """
  Order represents a confirmed production job derived from a Quote.

  Orders inherit:
    - jobs
    - tasks
    - pricing
    - production schedule

  """

  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "orders"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :order_number, :string

    attribute :customer_id, :uuid
    attribute :print_service_id, :uuid
    attribute :material_id, :uuid

    attribute :quantity, :integer

    attribute :dimensions, :string
    attribute :colors, :integer
    attribute :finish, :string

    attribute :status, :string, default: "pending"
    # pending | scheduled | in_production | completed | cancelled

    attribute :order_date, :utc_datetime
    attribute :delivery_date, :utc_datetime

    attribute :total_price, :decimal

    attribute :notes, :string

    attribute :custom_specifications, :map
  end

  relationships do
    belongs_to :customer, Framework.Accounts.User
    belongs_to :print_service, Framework.Services.PrintService
    belongs_to :material, Framework.Services.Material

    has_many :jobs, Framework.Services.OrderJob
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    create :from_quote do
      accept [
        :customer_id,
        :print_service_id,
        :material_id,
        :quantity,
        :dimensions,
        :colors,
        :finish,
        :total_price,
        :notes,
        :custom_specifications
      ]

      change fn changeset, _ ->
        changeset
        |> Ash.Changeset.change_attribute(:status, "pending")
        |> Ash.Changeset.change_attribute(:order_date, DateTime.utc_now())
        |> Ash.Changeset.change_attribute(:order_number, generate_order_number())
      end
    end
  end

  # =========================
  # ORDER NUMBER GENERATION
  # =========================

  defp generate_order_number do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    "ORD-#{timestamp}-#{:rand.uniform(9999)}"
  end
end