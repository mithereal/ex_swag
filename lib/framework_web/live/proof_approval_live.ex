defmodule FrameworkWeb.ProofApprovalLive do
  use FrameworkWeb, :live_view

  alias Framework.Services

  @impl true
  def mount(%{"id" => proof_id}, _session, socket) do
    Phoenix.PubSub.subscribe(Framework.PubSub, "proof:#{proof_id}")

    proof = load_proof(proof_id)

    {:ok,
      socket
      |> assign(:proof, proof)
      |> assign(:revision, latest_revision(proof))}
  end

  # =========================
  # CUSTOMER ACTIONS
  # =========================

  def handle_event("approve", _, socket) do
    proof = socket.assigns.proof

    Services.Proof
    |> Ash.get!(proof.id)
    |> Services.Proof.approve!()

    {:noreply, socket}
  end

  def handle_event("reject", _, socket) do
    proof = socket.assigns.proof

    Services.Proof
    |> Ash.get!(proof.id)
    |> Services.Proof.reject!()

    {:noreply, socket}
  end

  # =========================
  # REAL-TIME UPDATES
  # =========================

  def handle_info({:approved, _proof}, socket) do
    {:noreply, assign(socket, :proof, reload(socket))}
  end

  def handle_info({:rejected, _proof}, socket) do
    {:noreply, assign(socket, :proof, reload(socket))}
  end

  # =========================
  # HELPERS
  # =========================

  defp load_proof(id) do
    Services.Proof
    |> Ash.Query.load([:files, :revisions])
    |> Ash.get!(id)
  end

  defp reload(socket), do: load_proof(socket.assigns.proof.id)

  defp latest_revision(proof) do
    Enum.max_by(proof.revisions, & &1.revision_number, fn -> nil end)
  end
end