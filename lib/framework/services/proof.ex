defmodule Framework.Services.Proof do
  @moduledoc """
  A Proof is a customer-facing review package tied to a Quote.

  It contains:
    - files (assets/designs)
    - revisions
    - approval state
    - optional price overrides per line item
  """

  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "proofs"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :quote_id, :uuid, allow_nil?: false

    attribute :status, :string, default: "draft"
    # draft | sent | approved | rejected

    attribute :current_revision, :integer, default: 1

    attribute :created_by, :uuid
    attribute :approved_by, :uuid
    attribute :approved_at, :utc_datetime
  end

  relationships do
    belongs_to :quote, Framework.Services.Quote
    has_many :files, Framework.Services.ProofFile
    has_many :revisions, Framework.Services.ProofRevision
  end

  actions do
    defaults [:read, :create, :update]

    update :send_for_review do
      change set_attribute(:status, "sent")
    end

    update :approve do
      change set_attribute(:status, "approved")
      change set_attribute(:approved_at, &DateTime.utc_now/0)
    end

    update :reject do
      change set_attribute(:status, "rejected")
    end
  end
end