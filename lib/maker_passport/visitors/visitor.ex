defmodule MakerPassport.Visitors.Visitor do
  use Ecto.Schema
  import Ecto.Changeset

  @hash_algorithm :sha256
  @rand_size 32

  schema "visitors" do
    field :name, :string
    field :email, :string
    field :token, :binary
    field :is_verified, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def changeset(visitor, attrs \\ %{}) do
    visitor
    |> cast(attrs, [:name, :email, :token, :is_verified])
  end

  def generate_token() do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false), hashed_token}
  end

  def decode_token(token) do
    {:ok, decoded_token} = Base.url_decode64(token, padding: false)
    :crypto.hash(@hash_algorithm, decoded_token)
  end
end
