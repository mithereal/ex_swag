defmodule Framework.Inventory.Plugin do
  @behaviour Framework.Plugin

  def menu, do: []

  def widgets do
    [
      %{
        id: "inventory_count",
        title: "Inventory",
        value: fn _ -> 124 end,
        roles: [:admin, :staff]
      }
    ]
  end

  def enabled?(_), do: true
end

