defmodule MakerPassport.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :subject, :string
      add :body, :text
      add :visitor_id, references(:visitors)
      add :profile_id, references(:profiles)

      timestamps(type: :utc_datetime)
    end
  end
end
