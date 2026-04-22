defmodule Framework.Services do
  use Ash.Domain

  resources do
    resource Framework.Services.Quote
    resource Framework.Services.QuoteApproval
    resource Framework.Services.Order
    resource Framework.Services.Job
    resource Framework.Services.JobPreset
    resource Framework.Services.PresetTask
    resource Framework.Services.Task
    resource Framework.Services.WorkCenter
    resource Framework.Services.CapacitySlot
  end
end