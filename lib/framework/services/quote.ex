defmodule Framework.Services.Quote do
  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "quotes"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :status, :string, default: "draft"
    attribute :customer_id, :uuid

    attribute :estimated_price, :decimal
    attribute :risk_score, :integer
  end

  relationships do
    has_many :jobs, Framework.Services.Job
    has_one :approval, Framework.Services.QuoteApproval
  end

  actions do
    defaults [:read, :create, :update]

    update :submit_for_approval do
      change set_attribute(:status, "pending_approval")
    end
  end
end