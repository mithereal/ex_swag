defmodule Framework.Dashboard.Widgets.Overview do
  alias Framework.Sales.OrderOverview

  def widget do
    %PhoenixKit.Dashboard.Widget{
      uuid: "overview-widget",
      name: "Overview",
      description: "Order overview",
      value: &render/1
    }
  end

  def render(user) do
    overview =
      OrderOverview
      |> Ash.Query.for_read(:read)
      |> Ash.read_one!(actor: user)

    Phoenix.Component.render(
      &FrameworkWeb.Components.OverviewWidget.render/1,
      %{
        id: "overview",
        overview: overview,
        current_user: user
      }
    )
  end
end
