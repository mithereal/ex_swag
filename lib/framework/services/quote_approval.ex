defmodule Framework.Services.QuoteApproval do
  @moduledoc """
  Approval gate between Quote and Order.

  Responsible for:
    - submission workflow
    - human approval / rejection
    - auto-approval integration
    - event broadcasting for LiveView reactivity
  """

  use Ash.Resource,
      domain: Framework.Services,
      data_layer: AshPostgres.DataLayer

  alias Framework.PubSub

  postgres do
    table "quote_approvals"
    repo Framework.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :quote_id, :uuid, allow_nil?: false

    attribute :status, :string, default: "pending"
    # pending | approved | rejected | auto_approved

    attribute :submitted_by, :uuid
    attribute :decided_by, :uuid

    attribute :submitted_at, :utc_datetime
    attribute :decided_at, :utc_datetime

    attribute :notes, :string

    # snapshot for traceability
    attribute :risk_score_snapshot, :integer
    attribute :margin_snapshot, :decimal
    attribute :eta_snapshot, :utc_datetime
  end

  relationships do
    belongs_to :quote, Framework.Services.Quote
  end

  actions do
    defaults [:read, :create, :update]

    # =========================
    # SUBMIT FOR APPROVAL
    # =========================
    create :submit do
      accept [:quote_id, :submitted_by, :notes]

      change fn cs, _ ->
        cs
        |> Ash.Changeset.change_attribute(:status, "pending")
        |> Ash.Changeset.change_attribute(:submitted_at, DateTime.utc_now())
      end

      after_action fn _changeset, approval, _context ->
        broadcast(approval, :submitted)
        {:ok, approval}
      end
    end

    # =========================
    # APPROVE
    # =========================
    update :approve do
      accept [:decided_by]

      change fn cs, _ ->
        cs
        |> Ash.Changeset.change_attribute(:status, "approved")
        |> Ash.Changeset.change_attribute(:decided_at, DateTime.utc_now())
      end

      after_action fn _changeset, approval, _context ->
        broadcast(approval, :approved)
        {:ok, approval}
      end
    end

    # =========================
    # REJECT
    # =========================
    update :reject do
      accept [:decided_by, :notes]

      change fn cs, _ ->
        cs
        |> Ash.Changeset.change_attribute(:status, "rejected")
        |> Ash.Changeset.change_attribute(:decided_at, DateTime.utc_now())
      end

      after_action fn _changeset, approval, _context ->
        broadcast(approval, :rejected)
        {:ok, approval}
      end
    end

    # =========================
    # AUTO APPROVAL (from intelligence engine)
    # =========================
    update :auto_approve do
      change fn cs, _ ->
        cs
        |> Ash.Changeset.change_attribute(:status, "auto_approved")
        |> Ash.Changeset.change_attribute(:decided_at, DateTime.utc_now())
      end

      after_action fn _changeset, approval, _context ->
        broadcast(approval, :auto_approved)
        {:ok, approval}
      end
    end
  end

  # =========================
  # PUBSUB EVENT SYSTEM
  # =========================

  defp broadcast(approval, event) do
    # quote-level stream (primary for LiveView cockpit)
    Phoenix.PubSub.broadcast(
      PubSub,
      "quote:#{approval.quote_id}",
      {event, approval}
    )

    # approval-level stream (audit / admin dashboards)
    Phoenix.PubSub.broadcast(
      PubSub,
      "approval:#{approval.id}",
      {event, approval}
    )

    # global monitoring stream (optional ops dashboard)
    Phoenix.PubSub.broadcast(
      PubSub,
      "approvals",
      {event, approval}
    )
  end
end