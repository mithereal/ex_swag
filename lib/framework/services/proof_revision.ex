defmodule Framework.Services.ProofRevision do
  @moduledoc """
  Immutable snapshot per Proof revision.

  Stores:
    - version number
    - line item overrides
    - notes
  """

  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "proof_revisions"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :proof_id, :uuid, allow_nil?: false

    attribute :revision_number, :integer, allow_nil?: false

    attribute :notes, :string

    # JSON structure:
    # [
    #   %{line_item_id: "...", override_price: 12.50}
    # ]
    attribute :price_overrides, :map

    attribute :created_by, :uuid
    attribute :created_at, :utc_datetime, default: &DateTime.utc_now/0
  end

  relationships do
    belongs_to :proof, Framework.Services.Proof
  end

  actions do
    defaults [:read, :create]
  end
end