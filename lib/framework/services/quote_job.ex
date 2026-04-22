defmodule Framework.Services.QuoteJob do
  @moduledoc """
  QuoteJob represents a production unit inside a Quote.

  A Quote can have many Jobs.
  Each Job becomes an executable unit once converted to an Order.
  """

  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  alias Framework.Services.{JobPreset, PrintService}

  postgres do
    table "quote_jobs"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    # Ownership
    attribute :quote_id, :uuid, allow_nil?: false

    # Core configuration
    attribute :print_service_id, :uuid, allow_nil?: false
    attribute :job_preset_id, :uuid

    attribute :quantity, :integer, allow_nil?: false

    # Optional overrides (quote-level customization)
    attribute :custom_name, :string
    attribute :notes, :string

    # Pricing snapshot (frozen at quote time)
    attribute :unit_price, :decimal
    attribute :total_price, :decimal

    # Scheduling hints (used in simulation/approval)
    attribute :estimated_duration_minutes, :integer
    attribute :risk_flags, {:array, :string}, default: []
  end

  relationships do
    belongs_to :quote, Framework.Services.Quote
    belongs_to :print_service, Framework.Services.PrintService
    belongs_to :job_preset, Framework.Services.JobPreset

    has_many :tasks, Framework.Services.Task
  end

  actions do
    defaults [:read, :create, :update, :destroy]

    create :build do
      accept [
        :quote_id,
        :print_service_id,
        :job_preset_id,
        :quantity,
        :custom_name,
        :notes
      ]

      change fn changeset, _ ->
        quantity = Ash.Changeset.get_attribute(changeset, :quantity)

        service_id = Ash.Changeset.get_attribute(changeset, :print_service_id)

        service =
          PrintService
          |> Ash.get!(service_id)

        unit_price = service.base_price

        total_price =
          Decimal.mult(unit_price, quantity)

        changeset
        |> Ash.Changeset.change_attribute(:unit_price, unit_price)
        |> Ash.Changeset.change_attribute(:total_price, total_price)
      end
    end
  end

  alias Framework.Services.ETA.BusinessDaysETA

  def calculate_eta(job) do
    total_minutes =
      Enum.reduce(job.tasks, 0, fn t, acc ->
        acc + t.duration_minutes
      end)

    BusinessDaysETA.estimate(
      DateTime.utc_now(),
      total_minutes,
      rush_factor: 1.3
    )
  end
end