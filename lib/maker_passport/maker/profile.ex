defmodule MakerPassport.Maker.Profile do
  @moduledoc """
  A Maker's profile.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias MakerPassport.Accounts.User
  alias MakerPassport.Maker.{Skill, Website}

  schema "profiles" do
    field :bio, :string
    field :name, :string
    field :profile_image_location, :string, default: ""

    belongs_to :user, User
    has_many :websites, Website

    many_to_many :skills, Skill,
      join_through: "profile_skills",
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:name, :bio, :profile_image_location])
    |> validate_required([:name])

    # |> foreign_key_constraint(:user_id)
    # |> unique_constraint(:user_id)
  end

  def profile_complete?(%User{profile: profile}) when not is_nil(profile) do
    # Add all required profile fields here
    not is_nil(profile.name) and
      not is_nil(profile.bio) and
      not is_nil(profile.profile_image_location)

    # Add other required fields
  end

  def profile_complete?(_user), do: false
end
