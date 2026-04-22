defmodule Framework.Services.JobPreset do
  @moduledoc """
  A JobPreset defines a reusable production workflow template.

  Example:
    - Business Cards
    - Large Format Banner
    - Flyer Print + Cut + Pack
  """

  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "job_presets"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :description, :string

    # classification for filtering UI / quoting
    attribute :service_type, :string

    # optional: expected base duration (for simulation)
    attribute :base_duration_minutes, :integer, default: 0

    # optional: default risk modifier
    attribute :risk_level, :string, default: "normal"
  end

  relationships do
    has_many :preset_tasks, Framework.Services.PresetTask
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end
end