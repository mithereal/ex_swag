defmodule Framework.Services.PresetTask do
  @moduledoc """
  A PresetTask is a reusable step inside a JobPreset.

  When a Job is created from a preset,
  these become real Task records.
  """

  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "preset_tasks"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :job_preset_id, :uuid, allow_nil?: false

    attribute :name, :string, allow_nil?: false

    # ordering in workflow
    attribute :sequence, :integer, allow_nil?: false

    # production behavior
    attribute :duration_minutes, :integer, allow_nil?: false

    # mapping to production resources
    attribute :work_center_id, :uuid

    # optional: affects scheduling priority
    attribute :priority_weight, :integer, default: 0

    # optional: notes for operators
    attribute :instructions, :string
  end

  relationships do
    belongs_to :job_preset, Framework.Services.JobPreset
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end
end