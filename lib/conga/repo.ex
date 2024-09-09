defmodule Conga.Repo do
  use Ecto.Repo,
    otp_app: :conga,
    adapter: Ecto.Adapters.Postgres
end
