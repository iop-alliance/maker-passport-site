defmodule MakerPassport.Maker.Website do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias MakerPassport.Maker.Profile

  schema "maker_websites" do
    field :title, :string
    field :url, :string

    belongs_to :profile, Profile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(website, attrs \\ %{}) do
    website
    |> cast(attrs, [:title, :url, :profile_id])
    |> validate_required([:title, :url, :profile_id])
    |> validate_url(:url)
  end

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      case URI.parse(value) do
        %URI{scheme: scheme, host: host} when not is_nil(scheme) and not is_nil(host) ->
          []

        _ ->
          [{field, "must be a valid URL"}]
      end
    end)
  end
end
