defmodule Framework.Designs do
  @moduledoc """
  The Designs context for managing design proofs and approvals.
  """

  import Ecto.Query, warn: false
  alias Framework.Repo
  alias Framework.Designs.{Design, ProofSetting}

  @doc """
  Gets a single design by ID.
  """
  def get_design!(id) do
    Repo.get!(Design, id)
  end

  @doc """
  Gets or creates proof settings for a user and design.
  """
  def get_or_create_proof_settings(user_id, design_id) do
    case Repo.get_by(ProofSetting, user_id: user_id, design_id: design_id) do
      nil ->
        %ProofSetting{}
        |> ProofSetting.changeset(%{user_id: user_id, design_id: design_id})
        |> Repo.insert()

      setting ->
        {:ok, setting}
    end
  end

  @doc """
  Updates proof settings.
  """
  def update_proof_settings(%ProofSetting{} = proof_setting, attrs) do
    proof_setting
    |> ProofSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Approves a design and records the approval.
  """
  def approve_design(user_id, design_id) do
    with {:ok, proof_setting} <- get_or_create_proof_settings(user_id, design_id),
         {:ok, updated_setting} <-
           update_proof_settings(proof_setting, %{approved_at: DateTime.utc_now()}) do
      {:ok, updated_setting}
    end
  end

  @doc """
  Rejects a design with a reason.
  """
  def reject_design(user_id, design_id, reason) do
    with {:ok, proof_setting} <- get_or_create_proof_settings(user_id, design_id),
         {:ok, updated_setting} <-
           update_proof_settings(proof_setting, %{
             rejected_at: DateTime.utc_now(),
             rejection_reason: reason
           }) do
      {:ok, updated_setting}
    end
  end

  @doc """
  Gets the approval status for a design by a specific user.
  """
  def get_approval_status(user_id, design_id) do
    case Repo.get_by(ProofSetting, user_id: user_id, design_id: design_id) do
      %ProofSetting{approved_at: %DateTime{}} ->
        :approved

      %ProofSetting{rejected_at: %DateTime{}} ->
        :rejected

      %ProofSetting{} ->
        :pending

      nil ->
        :not_started
    end
  end

  @doc """
  Lists all proof settings for a design.
  """
  def list_proof_settings_for_design(design_id) do
    from(ps in ProofSetting, where: ps.design_id == ^design_id)
    |> Repo.all()
  end

  @doc """
  Gets approval summary for a design (counts of approvals/rejections).
  """
  def get_approval_summary(design_id) do
    settings = list_proof_settings_for_design(design_id)

    %{
      total: Enum.count(settings),
      approved: Enum.count(settings, &(&1.approved_at != nil)),
      rejected: Enum.count(settings, &(&1.rejected_at != nil)),
      pending: Enum.count(settings, &(&1.approved_at == nil && &1.rejected_at == nil))
    }
  end
end
