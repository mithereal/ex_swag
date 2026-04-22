defmodule Framework.Services.Calendar do
  @moduledoc """
  Business calendar logic for scheduling.

  Handles:
    - weekends
    - holidays
    - working hours
  """

  @working_days [:monday, :tuesday, :wednesday, :thursday, :friday]

  def working_day?(datetime) do
    datetime
    |> DateTime.to_date()
    |> Date.day_of_week()
    |> day_to_atom()
    |> then(&(&1 in @working_days))
  end

  def skip_weekends(datetime, minutes) do
    do_add(datetime, minutes)
  end

  defp do_add(dt, minutes) do
    next = DateTime.add(dt, minutes * 60, :second)

    if working_day?(next) do
      next
    else
      next_workday_start(next)
      |> do_add(0)
    end
  end

  defp next_workday_start(datetime) do
    datetime
    |> DateTime.add(24 * 60 * 60, :second)
    |> DateTime.truncate(:second)
  end

  defp day_to_atom(1), do: :monday
  defp day_to_atom(2), do: :tuesday
  defp day_to_atom(3), do: :wednesday
  defp day_to_atom(4), do: :thursday
  defp day_to_atom(5), do: :friday
  defp day_to_atom(6), do: :saturday
  defp day_to_atom(7), do: :sunday
end