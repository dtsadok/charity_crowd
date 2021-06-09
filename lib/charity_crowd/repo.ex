defmodule CharityCrowd.Repo do
  use Ecto.Repo,
    otp_app: :charity_crowd,
    adapter: Ecto.Adapters.Postgres
end
