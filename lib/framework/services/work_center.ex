defmodule Framework.Services.WorkCenter do
  @moduledoc """
  A WorkCenter is a physical or logical production resource.

  Examples:
    - Offset Press
    - Digital Printer
    - Cutter
    - Packaging Station
  """

  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "work_centers"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
    attribute :type, :string

    # throughput tuning
    attribute :efficiency_factor, :float, default: 1.0

    # optional constraints
    attribute :max_job_size, :integer
    attribute :is_active, :boolean, default: true
  end

  relationships do
    has_many :capacity_slots, Framework.Services.CapacitySlot
    has_many :preset_tasks, Framework.Services.PresetTask
    has_many :tasks, Framework.Services.Task
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end
end