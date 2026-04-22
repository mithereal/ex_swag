alias Framework.Repo
alias Framework.Services

IO.puts("Seeding production ERP dataset...")

# =========================
# WORK CENTERS
# =========================

press =
  Services.WorkCenter
  |> Ash.Changeset.for_create(:create, %{
    name: "Offset Press 1",
    type: "press",
    efficiency_factor: 1.1
  })
  |> Ash.create!()

cutter =
  Services.WorkCenter
  |> Ash.Changeset.for_create(:create, %{
    name: "Cutter A",
    type: "cutting",
    efficiency_factor: 1.0
  })
  |> Ash.create!()

pack =
  Services.WorkCenter
  |> Ash.Changeset.for_create(:create, %{
    name: "Packing Station",
    type: "packaging",
    efficiency_factor: 0.9
  })
  |> Ash.create!()

# =========================
# CAPACITY SLOTS
# =========================

for wc <- [press, cutter, pack] do
  for day <- 0..5 do
    Services.CapacitySlot
    |> Ash.Changeset.for_create(:create, %{
      work_center_id: wc.id,
      start_at: DateTime.add(DateTime.utc_now(), day * 86_400, :second),
      end_at: DateTime.add(DateTime.utc_now(), day * 86_400 + 28_800, :second),
      capacity_minutes: 480,
      used_minutes: 120
    })
    |> Ash.create!()
  end
end

# =========================
# PRINT SERVICE
# =========================

business_cards =
  Services.PrintService
  |> Ash.Changeset.for_create(:create, %{
    name: "Business Cards",
    service_type: "print",
    base_price: Decimal.new("0.08"),
    turnaround_days: 3,
    min_order_quantity: 100
  })
  |> Ash.create!()

# =========================
# JOB PRESET
# =========================

preset =
  Services.JobPreset
  |> Ash.Changeset.for_create(:create, %{
    name: "Business Card Standard",
    description: "Print → Cut → Pack",
    service_type: "print",
    base_duration_minutes: 240
  })
  |> Ash.create!()

# =========================
# PRESET TASKS
# =========================

Services.PresetTask
|> Ash.Changeset.for_create(:create, %{
  job_preset_id: preset.id,
  name: "Print Cards",
  sequence: 1,
  duration_minutes: 120,
  work_center_id: press.id
})
|> Ash.create!()

Services.PresetTask
|> Ash.Changeset.for_create(:create, %{
  job_preset_id: preset.id,
  name: "Cut Sheets",
  sequence: 2,
  duration_minutes: 90,
  work_center_id: cutter.id
})
|> Ash.create!()

Services.PresetTask
|> Ash.Changeset.for_create(:create, %{
  job_preset_id: preset.id,
  name: "Pack Orders",
  sequence: 3,
  duration_minutes: 60,
  work_center_id: pack.id
})
|> Ash.create!()

# =========================
# QUOTE
# =========================

quote =
  Services.Quote
  |> Ash.Changeset.for_create(:create, %{
    status: "draft"
  })
  |> Ash.create!()

# =========================
# QUOTE JOB
# =========================

quote_job =
  Services.QuoteJob
  |> Ash.Changeset.for_create(:build, %{
    quote_id: quote.id,
    print_service_id: business_cards.id,
    job_preset_id: preset.id,
    quantity: 1000
  })
  |> Ash.create!()

# =========================
# TASKS (from preset simulation)
# =========================

now = DateTime.utc_now()

for {name, seq, wc, mins} <- [
  {"Print Cards", 1, press.id, 120},
  {"Cut Sheets", 2, cutter.id, 90},
  {"Pack Orders", 3, pack.id, 60}
] do
  Services.Task
  |> Ash.Changeset.for_create(:create, %{
    job_id: quote_job.id,
    name: name,
    sequence: seq,
    status: "pending",
    duration_minutes: mins,
    scheduled_start: DateTime.add(now, seq * 3600, :second),
    scheduled_end: DateTime.add(now, seq * 3600 + mins * 60, :second)
  })
  |> Ash.create!()
end

# =========================
# PROOF + REVISION
# =========================

proof =
  Services.Proof
  |> Ash.Changeset.for_create(:create, %{
    quote_id: quote.id,
    status: "sent"
  })
  |> Ash.create!()

Services.ProofRevision
|> Ash.Changeset.for_create(:create, %{
  proof_id: proof.id,
  revision_number: 1,
  notes: "Initial proof for customer approval",
  price_overrides: [
    %{
      "quote_job_id" => quote_job.id,
      "override_price" => "0.12"
    }
  ]
})
|> Ash.create!()

# =========================
# APPROVAL RECORD
# =========================

Services.QuoteApproval
|> Ash.Changeset.for_create(:submit, %{
  quote_id: quote.id,
  submitted_by: Ecto.UUID.generate()
})
|> Ash.create!()

IO.puts("Seeding complete ✔")
IO.puts("Quote ID: #{quote.id}")