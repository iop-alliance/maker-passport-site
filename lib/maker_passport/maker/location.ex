defmodule MakerPassport.Maker.Location do
  @moduledoc """
  A Maker's profile location.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :country, :string
    field :city, :string
    field :latitude, :float
    field :longitude, :float

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(location, attrs \\ %{}) do
    location
    |> cast(attrs, [:country, :city, :latitude, :longitude])
  end
end
