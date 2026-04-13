defmodule Framework.Repo do
  use Ecto.Repo,
    otp_app: :framework,
    adapter: Ecto.Adapters.Postgres
end
