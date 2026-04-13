# lib/print_industry/print_industry.ex

defmodule Framework.Services do
  @moduledoc """
  PrintIndustry context handles all business logic for print services,
  orders, quotes, and materials.
  """

  import Ecto.Query, warn: false
  alias Framework.Repo
  alias PrintIndustry.{PrintService, Order, Quote, Material}

  # ============================================================================
  # Print Services
  # ============================================================================

  def list_print_services(filters \\ []) do
    PrintService
    |> apply_filters(filters)
    |> Repo.all()
  end

  def get_print_service!(id), do: Repo.get!(PrintService, id)

  def create_print_service(attrs \\ %{}) do
    %PrintService{}
    |> PrintService.changeset(attrs)
    |> Repo.insert()
  end

  def update_print_service(%PrintService{} = service, attrs) do
    service
    |> PrintService.changeset(attrs)
    |> Repo.update()
  end

  def delete_print_service(%PrintService{} = service) do
    Repo.delete(service)
  end

  # ============================================================================
  # Orders
  # ============================================================================

  def list_orders(filters \\ []) do
    Order
    |> apply_filters(filters)
    |> Repo.all()
  end

  def get_order!(id), do: Repo.get!(Order, id)

  def create_order(attrs \\ %{}) do
    %Order{}
    |> Order.changeset(attrs)
    |> Repo.insert()
  end

  def update_order(%Order{} = order, attrs) do
    order
    |> Order.changeset(attrs)
    |> Repo.update()
  end

  def change_order(%Order{} = order, attrs \\ %{}) do
    Order.changeset(order, attrs)
  end

  # ============================================================================
  # Quotes
  # ============================================================================

  def list_quotes(filters \\ []) do
    Quote
    |> apply_filters(filters)
    |> Repo.all()
  end

  def get_quote!(id), do: Repo.get!(Quote, id)

  def create_quote(attrs \\ %{}) do
    %Quote{}
    |> Quote.changeset(attrs)
    |> Repo.insert()
  end

  def generate_quote(print_service_id, quantity, material_id) do
    service = get_print_service!(print_service_id)
    material = if material_id, do: Repo.get!(Material, material_id), else: nil

    material_cost = if material, do: Decimal.mult(material.cost_per_unit, quantity), else: Decimal.new(0)
    base_cost = Decimal.mult(service.base_price, quantity)
    labor_cost = Decimal.new(50)  # Base labor cost

    subtotal = Decimal.add(base_cost, material_cost) |> Decimal.add(labor_cost)
    markup = Decimal.mult(subtotal, Decimal.new("0.25"))
    total = Decimal.add(subtotal, markup)

    %{
      estimated_price: total,
      material_cost: material_cost,
      labor_cost: labor_cost,
      markup_percentage: Decimal.new("25.0")
    }
  end

  # ============================================================================
  # Materials
  # ============================================================================

  def list_materials do
    Repo.all(Material)
  end

  def get_material!(id), do: Repo.get!(Material, id)

  def create_material(attrs \\ %{}) do
    %Material{}
    |> Material.changeset(attrs)
    |> Repo.insert()
  end

  # ============================================================================
  # Filters and Helpers
  # ============================================================================

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {:status, status}, q -> where(q, status: ^status)
      {:service_type, type}, q -> where(q, service_type: ^type)
      {:is_active, active}, q -> where(q, is_active: ^active)
      {:customer_id, id}, q -> where(q, customer_id: ^id)
      _, q -> q
    end)
  end

  def calculate_order_total(order) do
    service = get_print_service!(order.print_service_id)
    Decimal.mult(service.base_price, order.quantity)
  end

  def update_order_status(%Order{} = order, new_status) do
    update_order(order, %{status: new_status})
  end
end
