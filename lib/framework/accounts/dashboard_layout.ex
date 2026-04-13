defmodule Framework.Accounts.DashboardLayout do
  use Ecto.Schema

  schema "dashboard_layouts" do
    field :widget_id, :string
    field :x, :integer
    field :y, :integer
    field :w, :integer
    field :h, :integer

    belongs_to :user, Framework.Accounts.User
    timestamps()
  end
end