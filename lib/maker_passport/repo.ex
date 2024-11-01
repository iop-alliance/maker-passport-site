defmodule MakerPassport.Repo do
  use Ecto.Repo,
    otp_app: :maker_passport,
    adapter: Ecto.Adapters.Postgres
end
