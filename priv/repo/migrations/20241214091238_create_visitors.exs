defmodule MakerPassport.Repo.Migrations.CreateVisitors do
  use Ecto.Migration

  def change do
    create table(:visitors) do
      add :name, :string
      add :email, :string
      add :token, :binary
      add :is_verified, :boolean, default: false

      timestamps(type: :utc_datetime)
    end
  end
end
