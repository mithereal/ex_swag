defmodule Framework.Services.CapacitySlot do
  @moduledoc """
  A CapacitySlot represents available production time for a WorkCenter.

  Example:
    - Press #1: 08:00 → 16:00
    - Cutter: 10:00 → 18:00
  """

  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  postgres do
    table "capacity_slots"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :work_center_id, :uuid, allow_nil?: false

    attribute :start_at, :utc_datetime, allow_nil?: false
    attribute :end_at, :utc_datetime, allow_nil?: false

    # total available minutes in slot
    attribute :capacity_minutes, :integer, allow_nil?: false, default: 480

    # consumed minutes by scheduled tasks
    attribute :used_minutes, :integer, default: 0

    # optional: shift type (day/night/maintenance)
    attribute :shift_type, :string, default: "day"
  end

  relationships do
    belongs_to :work_center, Framework.Services.WorkCenter
  end

  actions do
    defaults [:read, :create, :update, :destroy]
  end

  calculations do
    calculate :available_minutes, :integer, expr(capacity_minutes - used_minutes)
  end
end