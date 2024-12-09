defmodule MakerPassport.Repo.Migrations.AlterProfilesAddLocationId do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :location_id, references(:locations)
    end
  end
end
