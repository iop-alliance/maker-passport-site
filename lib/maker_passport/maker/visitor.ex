defmodule MakerPassport.Maker.Visitor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "visitors" do
    field :name, :string
    field :email, :string
    field :token, :string
    field :is_verified, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def changeset(visitor, attrs \\ %{}) do
    visitor
    |> cast(attrs, [:name, :email, :token, :is_verified])
  end
end
