defmodule MakerPassport.Maker.Certification do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias MakerPassport.Maker.Profile

  schema "maker_certifications" do
    field :issue_date, :date
    field :issuer_name, :string
    field :title, :string
    field :url, :string

    belongs_to :profile, Profile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(certification, attrs \\ %{}) do
    certification
    |> cast(attrs, [:title, :issuer_name, :issue_date, :url, :profile_id])
    |> validate_required([:title, :issuer_name, :issue_date, :profile_id])
  end
end
