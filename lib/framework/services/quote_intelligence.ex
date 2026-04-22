defmodule Framework.Services.QuoteIntelligence do
  alias Decimal, as: D

  def analyze(quote) do
    margin = estimate_margin(quote)
    capacity_risk = 0.25
    sla_risk = 0.15

    score =
      100
      |> Kernel.-(margin_penalty(margin))
      |> Kernel.-(capacity_risk * 40)
      |> Kernel.-(sla_risk * 30)

    %{
      margin: margin,
      score: score,
      auto_approve: score > 85
    }
  end

  defp estimate_margin(_q), do: 0.32

  defp margin_penalty(m) when m < 0.2, do: 40
  defp margin_penalty(m) when m < 0.3, do: 15
  defp margin_penalty(_), do: 0
end