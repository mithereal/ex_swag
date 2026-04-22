defmodule Framework.PrintService do
  use Ash.Resource,
      data_layer: AshPostgres.DataLayer,
      domain: Framework.Services

  postgres do
    table "print_services"
    repo Framework.Repo
  end

  # === Attributes ===
  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :description, :string

    attribute :service_type, :string do
      allow_nil? false
    end

    attribute :base_price, :decimal do
      allow_nil? false
    end

    attribute :unit, :string do
      allow_nil? false
    end

    attribute :turnaround_days, :integer

    attribute :min_order_quantity, :integer

    attribute :specifications, :map do
      default %{}
    end

    attribute :is_active, :boolean do
      default true
    end

    attribute :created_by, :uuid

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  # === Actions ===
  actions do
    defaults [:read, :destroy]

    create :create do
      accept [
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
      ]
    end

    update :update do
      accept [
        :name,
        :description,
        :service_type,
        :base_price,
        :unit,
        :turnaround_days,
        :min_order_quantity,
        :specifications,
        :is_active
      ]
    end
  end

  # === Relationships (optional, future-proof) ===
  relationships do
    # Example:
    # belongs_to :creator, Framework.Accounts.User do
    #   source_attribute :created_by
    #   destination_attribute :id
    # end
  end

  # === Identities ===
  identities do
    identity :unique_service_name, [:name]
  end
end