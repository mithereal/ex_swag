defmodule Framework.Services.QuoteLineOverride do
  @moduledoc """
  Allows Proof revisions to override pricing per line item.
  """

  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "quote_line_overrides"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :quote_id, :uuid, allow_nil?: false
    attribute :quote_job_id, :uuid, allow_nil?: false

    attribute :proof_revision_id, :uuid

    attribute :override_price, :decimal
    attribute :reason, :string
  end

  relationships do
    belongs_to :quote, Framework.Services.Quote
    belongs_to :quote_job, Framework.Services.QuoteJob
    belongs_to :proof_revision, Framework.Services.ProofRevision
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end
end