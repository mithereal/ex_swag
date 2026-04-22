defmodule Framework.Services.Task do
  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "tasks"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :job_id, :uuid

    attribute :name, :string
    attribute :sequence, :integer

    attribute :scheduled_start, :utc_datetime
    attribute :scheduled_end, :utc_datetime

    attribute :status, :string, default: "pending"
    attribute :notes, :string
  end

  actions do
    update :mark_done do
      change set_attribute(:status, "done")
    end

    update :reschedule do
      accept [:scheduled_start, :scheduled_end]
    end
  end
end