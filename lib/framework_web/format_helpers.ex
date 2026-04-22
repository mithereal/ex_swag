defmodule FrameworkWeb.FormatHelpers do
  def format_date(nil), do: "—"

  def format_date(%Date{} = d) do
    Calendar.strftime(d, "%b %d, %Y")
  end
end
