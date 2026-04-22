defmodule Framework.Services.Pricing do
  @moduledoc """
  Central pricing engine.

  Combines:
    - base service cost
    - quantity scaling
    - preset complexity
    - rush factor
  """

  alias Decimal, as: D

  def calculate(%{base_price: base, quantity: qty} = opts) do
    rush_factor = Map.get(opts, :rush_factor, 1.0)
    complexity = Map.get(opts, :complexity_factor, 1.0)

    base_total =
      base
      |> D.mult(qty)

    base_total
    |> D.mult(D.new(complexity))
    |> D.mult(D.new(rush_factor))
  end

  def rush_multiplier(:none), do: 1.0
  def rush_multiplier(:standard), do: 1.2
  def rush_multiplier(:rush), do: 1.5
  def rush_multiplier(:critical), do: 2.0

  def complexity_from_preset(tasks) do
    base = length(tasks)

    cond do
      base <= 3 -> 1.0
      base <= 6 -> 1.2
      true -> 1.5
    end
  end
end