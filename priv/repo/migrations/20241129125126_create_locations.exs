defmodule MakerPassport.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :country, :string
      add :city, :string
      add :latitude, :float
      add :longitude, :float

      timestamps(type: :utc_datetime)
    end

    create unique_index(:locations, [:country, :city])
  end
end
