defmodule Framework.Services.QuoteSimulator do
  alias Framework.Services.Scheduler

  def simulate(quote) do
    timelines =
      Enum.map(quote.jobs, fn job ->
        schedule = Scheduler.schedule_job(job)

        %{
          job_id: job.id,
          start: schedule.start,
          end: schedule.end
        }
      end)

    %{
      feasible: Enum.all?(timelines, &DateTime.compare(&1.end, DateTime.utc_now()) == :gt),
      earliest_end: Enum.max_by(timelines, & &1.end).end
    }
  end
end