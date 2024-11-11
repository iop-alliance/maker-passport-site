defmodule MakerPassport.Maker.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  alias MakerPassport.Accounts.User

  schema "profiles" do
    field :bio, :string
    field :name, :string
    field :profile_image_location, :string, default: ""

    belongs_to :user, User

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
end
