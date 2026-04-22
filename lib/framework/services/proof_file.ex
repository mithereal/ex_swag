defmodule Framework.Services.ProofFile do
  @moduledoc """
  Files attached to a Proof revision.
  """

  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "proof_files"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :proof_id, :uuid, allow_nil?: false
    attribute :revision, :integer, allow_nil?: false

    attribute :file_url, :string
    attribute :file_type, :string

    attribute :uploaded_by, :uuid
  end

  relationships do
    belongs_to :proof, Framework.Services.Proof
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end
end