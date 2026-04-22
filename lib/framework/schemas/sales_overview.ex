defmodule Framework.Sales.OrderOverview do
  use Ash.Resource,
    domain: Framework.Sales,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "order_overviews"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key(:id)

    attribute(:payment_term, :string)
    attribute(:due_date, :date)
    attribute(:deposit_due, :date)
    attribute(:deposit_percent, :integer)

    attribute(:issue_date, :date)
    attribute(:production_start, :date)
    attribute(:production_due, :date)
    attribute(:in_hands_date, :date)

    attribute(:warehouse, :string)
    attribute(:created_by, :string)

    attribute(:pricing_group, :string)
    attribute(:pricing_strategy, :string)

    attribute(:customer_po, :string)
    attribute(:brand_profile, :string)
  end

  actions do
    defaults([:read, :update])
  end
end
