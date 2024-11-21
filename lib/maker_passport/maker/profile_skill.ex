defmodule MakerPassport.Maker.ProfileSkill do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias MakerPassport.Maker.{Profile, Skill}

  schema "profile_skills" do

    belongs_to :profile, Profile
    belongs_to :skill, Skill

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile_skill, attrs) do
    profile_skill
    |> cast(attrs, [:profile_id, :skill_id])
    |> validate_required([:profile_id, :skill_id])
  end
end
