defmodule MakerPassport.Repo.Migrations.CreateMakerWebsites do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:maker_websites) do
      add :title, :string, null: false
      add :url, :string, null: false
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:maker_websites, [:profile_id])
  end
end
