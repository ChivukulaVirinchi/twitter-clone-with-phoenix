defmodule XDemo.Repo do
  use Ecto.Repo,
    otp_app: :x_demo,
    adapter: Ecto.Adapters.Postgres
end
