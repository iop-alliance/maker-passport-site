defmodule MakerPassport.Repo.Migrations.CreateSkills do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:skills) do
      add :name, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:skills, [:name])


    create table(:profile_skills) do
      add :profile_id, references(:profiles, on_delete: :nothing)
      add :skill_id, references(:skills, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:profile_skills, [:profile_id])
    create index(:profile_skills, [:skill_id])
    create unique_index(:profile_skills, [:profile_id, :skill_id])
  end
end
