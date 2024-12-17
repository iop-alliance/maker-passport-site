defmodule MakerPassport.Maker.Email do
  @moduledoc """
  A Maker's profile location.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "emails" do
    field :subject, :string
    field :body, :string
    field :status, :string
    belongs_to :profile, MakerPassport.Maker.Profile
    belongs_to :visitor, MakerPassport.Maker.Visitor

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(email, attrs \\ %{}) do
    email
    |> cast(attrs, [:subject, :body, :status, :visitor_id, :profile_id])
    |> validate_required([:subject, :body])
  end
end
