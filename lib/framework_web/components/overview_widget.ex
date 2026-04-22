defmodule FrameworkWeb.Components.OverviewWidget do
  use FrameworkWeb, :live_component
  import FrameworkWeb.FormatHelpers

  alias Framework.Sales.OrderOverview

  def mount(socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(
        Framework.PubSub,
        "overview:#{socket.assigns.id}"
      )
    end

    {:ok, socket}
  end

  def update(assigns, socket) do
    form =
      assigns.overview
      |> AshPhoenix.Form.for_update(:update,
        actor: assigns.current_user,
        as: "overview"
      )

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, form)
     |> assign(:editing, false)}
  end

  def render(assigns) do
    ~H"""
    <div class="card bg-base-100 shadow-sm border border-base-300 h-full">
      <div class="card-body p-4 space-y-4">
        <div class="flex justify-between">
          <h3 class="font-semibold text-sm">Overview</h3>

          <button
            class="btn btn-xs btn-ghost"
            phx-click="edit"
            phx-target={@myself}
          >
            ✏️
          </button>
        </div>

        <%= if @editing do %>
          <.form for={@form} phx-submit="save" phx-target={@myself}>
            <div class="grid grid-cols-2 gap-3 text-sm">
              <.input field={@form[:payment_term]} label="Payment Term" />
              <.input field={@form[:deposit_percent]} label="Deposit %" type="number" />

              <.input field={@form[:due_date]} type="date" label="Due Date" />
              <.input field={@form[:deposit_due]} type="date" label="Deposit Due" />
            </div>

            <div class="flex justify-end gap-2 mt-4">
              <button type="button" phx-click="cancel" class="btn btn-xs">Cancel</button>
              <button class="btn btn-primary btn-xs" phx-disable-with="Saving...">Save</button>
            </div>
          </.form>
        <% else %>
          <div class="grid grid-cols-2 gap-y-3 gap-x-4 text-sm">
            <%= for {label, value, type} <- fields(@overview) do %>
              <div class="opacity-60">{label}</div>
              <div class="text-right font-medium truncate" title={display(value, type)}>
                {display(value, type)}
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("edit", _, socket) do
    {:noreply, assign(socket, :editing, true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, :editing, false)}
  end

  # optimistic update + async persist
  def handle_event("save", %{"overview" => params}, socket) do
    optimistic = Map.merge(socket.assigns.overview, params)

    Task.start(fn ->
      case Ash.update(socket.assigns.overview, params, actor: socket.assigns.current_user) do
        {:ok, updated} ->
          Phoenix.PubSub.broadcast(
            Framework.PubSub,
            "overview:#{updated.id}",
            %{event: "updated", payload: updated}
          )

        _ ->
          :noop
      end
    end)

    {:noreply,
     socket
     |> assign(:overview, optimistic)
     |> assign(:editing, false)}
  end

  def handle_info(%{event: "updated", payload: overview}, socket) do
    {:noreply, assign(socket, :overview, overview)}
  end

  # ------------------------
  # Field mapping
  # ------------------------

  defp fields(o) do
    [
      {"Payment Term", o.payment_term, :text},
      {"Due Date", o.due_date, :date},
      {"Deposit Due", o.deposit_due, :date},
      {"Deposit", o.deposit_percent, :percent},
      {"Issue Date", o.issue_date, :date},
      {"Prod. Start", o.production_start, :date},
      {"Prod. Due", o.production_due, :date},
      {"In Hands", o.in_hands_date, :date},
      {"Warehouse", o.warehouse, :text},
      {"Created By", o.created_by, :text},
      {"Pricing Group", o.pricing_group, :text},
      {"Pricing Strategy", o.pricing_strategy, :text},
      {"Customer PO", o.customer_po, :text},
      {"Brand Profile", o.brand_profile, :text}
    ]
  end

  defp display(nil, _), do: "—"
  defp display(v, :date), do: format_date(v)
  defp display(v, :percent), do: "#{v}%"
  defp display(v, _), do: v
end
