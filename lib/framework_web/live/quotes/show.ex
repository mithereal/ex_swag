defmodule FrameworkWeb.Quotes.Show do
  use FrameworkWeb, :live_view

  alias Framework.Services
  alias Framework.Services.ETA.BusinessDaysETA
  alias Framework.Services.QuoteIntelligence
  alias Ash.Query

  @impl true
  def mount(%{"id" => quote_id}, _session, socket) do
    Phoenix.PubSub.subscribe(Framework.PubSub, "quote:#{quote_id}")
    Phoenix.PubSub.subscribe(Framework.PubSub, "shop_floor")

    quote = load_quote(quote_id)

    {:ok,
      socket
      |> assign(:quote, quote)
      |> assign(:analysis, QuoteIntelligence.analyze(quote))
      |> assign(:eta, compute_eta(quote))
      |> assign(:loading, false)}
  end

  # =========================
  # APPROVAL FLOW
  # =========================

  def handle_event("send_for_approval", _, socket) do
    quote = socket.assigns.quote

    Services.QuoteApproval
    |> Ash.Changeset.for_create(:submit, %{
      quote_id: quote.id,
      submitted_by: socket.assigns.current_user.id
    })
    |> Ash.create!()

    {:noreply, put_flash(socket, :info, "Sent for approval")}
  end

  def handle_event("approve", %{"id" => approval_id}, socket) do
    approval = Services.QuoteApproval |> Ash.get!(approval_id)

    Services.QuoteApproval.approve!(approval)

    {:noreply, socket}
  end

  def handle_event("reject", %{"id" => approval_id}, socket) do
    approval = Services.QuoteApproval |> Ash.get!(approval_id)

    Services.QuoteApproval.reject!(approval)

    {:noreply, socket}
  end

  # =========================
  # REACTIVE EVENTS
  # =========================

  def handle_info({:approved, _approval}, socket) do
    quote = reload_quote(socket.assigns.quote.id)

    {:noreply, refresh(socket, quote, "Quote approved")}
  end

  def handle_info({:rejected, _approval}, socket) do
    quote = reload_quote(socket.assigns.quote.id)

    {:noreply, refresh(socket, quote, "Quote rejected")}
  end

  def handle_info({:task_updated, _task}, socket) do
    quote = reload_quote(socket.assigns.quote.id)

    {:noreply, refresh(socket, quote, "Shop floor updated")}
  end

  # =========================
  # CORE CALCULATIONS
  # =========================

  defp compute_eta(quote) do
    total_minutes =
      quote.jobs
      |> Enum.flat_map(& &1.tasks)
      |> Enum.map(& &1.duration_minutes)
      |> Enum.sum()

    BusinessDaysETA.estimate(
      DateTime.utc_now(),
      total_minutes,
      rush_factor: rush_factor(quote)
    )
  end

  defp rush_factor(_quote), do: 1.25

  # =========================
  # DATA LOADING
  # =========================

  defp load_quote(id) do
    Services.Quote
    |> Query.load([
      jobs: [:tasks, :print_service, :job_preset],
      approval: []
    ])
    |> Ash.get!(id)
  end

  defp reload_quote(id), do: load_quote(id)

  defp refresh(socket, quote, msg) do
    socket
    |> assign(:quote, quote)
    |> assign(:analysis, QuoteIntelligence.analyze(quote))
    |> assign(:eta, compute_eta(quote))
    |> put_flash(:info, msg)
  end
end