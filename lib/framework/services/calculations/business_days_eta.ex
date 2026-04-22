defmodule Framework.Services.ETA.BusinessDaysETA do
  @moduledoc """
  Computes ETA using business days, work hours, and scheduling rules.

  Used by:
    - Quote preview
    - Order scheduling
    - Simulation engine
  """

  alias Framework.Services.Calendar

  @work_day_minutes 8 * 60

  # Public API
  def estimate(start_at, total_minutes, opts \\ []) do
    rush_factor = Keyword.get(opts, :rush_factor, 1.0)
    skip_weekends = Keyword.get(opts, :skip_weekends, true)

    adjusted_minutes =
      (total_minutes * rush_factor)
      |> round()

    do_estimate(start_at, adjusted_minutes, skip_weekends)
  end

  # Core loop
  defp do_estimate(current, remaining_minutes, skip_weekends) when remaining_minutes <= 0 do
    current
  end

  defp do_estimate(current, remaining_minutes, skip_weekends) do
    current =
      if skip_weekends do
        advance_to_working_day(current)
      else
        current
      end

    available_today = available_work_minutes(current)

    {consumed, remaining} =
      cond do
        remaining_minutes <= available_today ->
          {remaining_minutes, 0}

        true ->
          {available_today, remaining_minutes - available_today}
      end

    next_time =
      DateTime.add(current, consumed * 60, :second)

    do_estimate(next_time, remaining, skip_weekends)
  end

  # Moves to next valid working day (Mon–Fri)
  defp advance_to_working_day(datetime) do
    if Calendar.working_day?(datetime) do
      datetime
    else
      datetime
      |> DateTime.add(24 * 60 * 60, :second)
      |> reset_to_start_of_day()
      |> advance_to_working_day()
    end
  end

  defp reset_to_start_of_day(dt) do
    %{dt | hour: 8, minute: 0, second: 0}
  end

  # Remaining working minutes in current day
  defp available_work_minutes(datetime) do
    end_of_day =
      %{datetime | hour: 16, minute: 0, second: 0}

    diff = DateTime.diff(end_of_day, datetime, :minute)

    max(diff, 0)
  end
end