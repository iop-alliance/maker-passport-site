defmodule MakerPassport.Maker.Location do
  @moduledoc """
  A Maker's profile location.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :country, :string
    field :city, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(location, attrs \\ %{}) do
    location
    |> cast(attrs, [:country, :city])
  end
end
