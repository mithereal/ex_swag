defmodule Framework.Services.Scheduler do
  def schedule_job(job) do
    start = DateTime.utc_now()
    duration = job.quantity * 10

    end_time = DateTime.add(start, duration * 60, :second)

    %{
      start: start,
      end: end_time
    }
  end
end