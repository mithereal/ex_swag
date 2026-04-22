# 🏭 Production System Overview (Quote → Proof → Order ERP Engine)

This system is a unified **quote, approval, design proofing, scheduling, and production execution platform**. It connects commercial quoting with real manufacturing constraints in real time.

---

# 🧭 1. System Architecture

The system is structured into four main layers:

Sales Layer → Quotes
Design Layer → Proofs + Revisions
Approval Layer → QuoteApproval + ProofApproval
Execution Layer → Orders + Jobs + Tasks


Each layer is traceable, event-driven, and feeds the next stage of production.

---

# 💰 2. Quote System (CPQ Engine)

## What a Quote is

A Quote is a **dynamic production simulation + pricing proposal**.

It contains:

- Print services
- Materials
- Quantity
- Jobs (QuoteJobs)
- Tasks (from presets)
- Pricing calculations
- ETA estimates

---

## QuoteJobs

A QuoteJob represents a production unit:

- Linked to a PrintService
- Uses a JobPreset
- Expands into Tasks

---

## Tasks

Tasks are atomic production steps:

- Print
- Cut
- Pack
- Finish work

Each task includes:

- start date
- end date
- duration
- status
- assigned WorkCenter

---

## Pricing Engine

Pricing is computed dynamically using:

- base service cost
- quantity scaling
- material cost
- labor cost
- complexity factor
- rush factor
- markup

Result:
→ Real-time quote pricing

---

## ETA Engine (BusinessDaysETA)

The system calculates delivery using:

- 8-hour workdays
- weekend skipping
- sequential task durations
- rush multipliers
- production flow simulation

Result:
→ Accurate production completion date (SLA-aware)

---

# 🧾 3. Proof System (Design + Revision Layer)

## What a Proof is

A Proof is a **customer-facing design review package** tied to a Quote.

It contains:

- design files
- revisions
- pricing overrides
- approval state

---

## Proof Files

Each Proof can include multiple files:

- artwork
- PDFs
- mockups
- previews

Files are tied to specific revisions.

---

## Proof Revisions

Each revision is an immutable snapshot containing:

- revision number
- notes
- updated files
- pricing overrides per line item

This ensures full auditability.

---

## Price Overrides

Proofs can override quote pricing per line item:

Example:
- Original: $0.10/unit
- Override: $0.12/unit

These overrides affect:

- margin recalculation
- approval risk score
- final order pricing

---

# ✅ 4. Approval System (Decision Gate)

There are two approval flows:

---

## QuoteApproval (Internal Gate)

Controls conversion from Quote → Order.

Statuses:

- pending
- approved
- rejected
- auto_approved

Stores snapshots:

- risk score
- margin
- ETA

This locks decision context at approval time.

---

## Proof Approval (Customer Gate)

Customers approve:

- design files
- revisions
- pricing adjustments

Once approved:
→ Proof becomes locked and eligible for production

---

## Real-time Behavior

All approval changes broadcast events via PubSub:

- `quote:<id>`
- `approval:<id>`
- `proof:<id>`
- `shop_floor`

LiveViews update instantly.

---

# 📦 5. Order System (Production Execution Layer)

## What an Order is

An Order is a **frozen production contract generated from a Quote**.

It includes:

- order number
- customer information
- service + material
- production specifications
- total price snapshot
- delivery date (SLA)

---

## Order Lifecycle
Quote Approved
↓
Order Created
↓
Jobs Materialized
↓
Tasks Scheduled
↓
Shop Floor Execution
↓
Completion

---

## Order Features

- deterministic order numbering
- frozen pricing snapshot
- inherited jobs and tasks
- production-ready scheduling

---

# 🏗 6. Production Layer (Shop Floor Model)

## WorkCenter

Represents production resources:

- printers
- cutters
- packaging stations

---

## CapacitySlot

Defines available production time:

- shift start/end
- capacity minutes
- used minutes

Used for scheduling and load balancing.

---

## JobPreset + PresetTask

Reusable production templates:

Example:

Business Cards:

Print
Cut
Pack

These expand into QuoteJobs and OrderJobs.

---

# 📅 7. Scheduling System

## BusinessDaysETA Engine

Ensures:

- weekends are excluded
- work hours respected
- production time simulated accurately
- rush factors applied

Result:
→ realistic delivery forecasting

---

# 🔄 8. Event-Driven Architecture

The system is fully reactive using PubSub.

## Event Streams

- quote updates
- task updates
- approval changes
- shop floor events

---

## Effect on UI

LiveViews automatically update:

- pricing changes
- ETA recalculation
- risk scoring
- approval dashboards

No manual refresh required.

---

# 🧠 9. Intelligence Layer

Emerging system capabilities:

- Quote risk scoring
- margin analysis
- auto-approval decisions
- schedule feasibility checks

This layer connects:

> commerce ↔ production ↔ execution

---

# 🚀 10. System Summary

This is not just a quoting tool.

It is a:

## Real-time Manufacturing Operating System

Combining:

- CPQ (Configure Price Quote)
- ERP (Orders + Customers)
- MES (Shop floor execution)
- Workflow engine (Approvals)
- Scheduling system (Capacity + ETA)
- Design review system (Proofs)

---

# 🧭 11. End-to-End Flow

Customer Request
↓
Quote (pricing + jobs + ETA simulation)
↓
Proof (design + revisions + overrides)
↓
Approval (risk + decision gate)
↓
Order (frozen production contract)
↓
Jobs → Tasks → WorkCenters
↓
Capacity Scheduling
↓
Shop Floor Execution

---

# 🔥 Final Insight

The system continuously transforms:

- static quotes → live simulations
- proofs → negotiated production artifacts
- approvals → risk-controlled decisions
- orders → immutable execution plans
- shop floor → reactive scheduling system

---
ng intelligence system