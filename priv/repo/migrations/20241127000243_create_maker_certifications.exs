defmodule MakerPassport.Repo.Migrations.CreateMakerCertifications do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:maker_certifications) do
      add :title, :string, null: false
      add :issuer_name, :string, null: false
      add :issue_date, :date, null: false
      add :url, :string
      add :profile_id, references(:profiles, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:maker_certifications, [:profile_id])
  end
end
