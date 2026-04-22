defmodule Framework.Services.Job do
  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "jobs"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :quote_id, :uuid
    attribute :service_id, :uuid
    attribute :quantity, :integer
    attribute :preset_id, :uuid
  end

  relationships do
    belongs_to :quote, Framework.Services.Quote
    has_many :tasks, Framework.Services.Task
  end
end