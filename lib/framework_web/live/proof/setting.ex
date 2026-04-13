defmodule Framework.Designs.ProofSetting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "design_proof_settings" do
    field :color_mode, :string, default: "rgb"
    field :show_guides, :boolean, default: false
    field :zoom_level, :integer, default: 100
    field :display_notes, :boolean, default: true
    field :client_name, :string
    field :approval_required, :boolean, default: true
    field :approved_at, :utc_datetime
    field :rejected_at, :utc_datetime
    field :rejection_reason, :string

    belongs_to :user, Framework.Accounts.User
    belongs_to :design, Framework.Designs.Design

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(proof_setting, attrs) do
    proof_setting
    |> cast(attrs, [
      :color_mode,
      :show_guides,
      :zoom_level,
      :display_notes,
      :client_name,
      :approval_required,
      :approved_at,
      :rejected_at,
      :rejection_reason,
      :user_id,
      :design_id
    ])
    |> validate_required([:user_id, :design_id])
    |> validate_inclusion(:color_mode, ["rgb", "cmyk"])
    |> validate_number(:zoom_level, greater_than_or_equal_to: 50, less_than_or_equal_to: 200)
    |> unique_constraint([:user_id, :design_id])
  end

  @doc false
  def approve_changeset(proof_setting, attrs) do
    proof_setting
    |> changeset(attrs)
    |> put_change(:approved_at, DateTime.utc_now())
    |> put_change(:rejected_at, nil)
    |> put_change(:rejection_reason, nil)
  end

  @doc false
  def reject_changeset(proof_setting, attrs) do
    proof_setting
    |> changeset(attrs)
    |> put_change(:rejected_at, DateTime.utc_now())
    |> put_change(:approved_at, nil)
  end
end
