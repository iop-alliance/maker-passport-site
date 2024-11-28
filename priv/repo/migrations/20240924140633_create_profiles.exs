defmodule MakerPassport.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :name, :string
      add :country, :string
      add :city, :string
      add :bio, :text
      add :profile_image_location, :string

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)

    end

    create unique_index(:profiles, [:user_id])  # Ensure a unique one-to-one relationship
  end
end
