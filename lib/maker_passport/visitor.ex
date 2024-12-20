defmodule MakerPassport.Visitor do

  import Ecto.Query, warn: false
  alias MakerPassport.Accounts
  alias MakerPassport.Repo

  alias MakerPassport.Visitors.{Visitor, Email}

  @doc """
  Gets a visitor by id.

  ## Examples

      iex> get_visitor!(1)
      {:ok, %Visitor{}}

      iex> get_visitor!(456)
      nil

  """
  def get_visitor!(id) do
    Repo.get!(Visitor, id)
  end

  @doc """
  Gets a visitor by token.

  ## Examples

      iex> get_visitor_by_token("token")
      {:ok, %Visitor{}}

      iex> get_visitor_by_token("bad_token")
      nil

  """
  def get_visitor_by_token(token) do
    token = Visitor.decode_token(token)
    Repo.get_by(Visitor, token: token)
  end

  @doc """
  Gets a visitor by email.

  ## Examples

      iex> get_visitor_by_email("email")
      {:ok, %Visitor{}}

      iex> get_visitor_by_email("bad_email")
      nil

  """
  def get_visitor_by_email(email) do
    Repo.get_by(Visitor, email: email)
  end

  @doc """
  Creates a verify visitor.

  ## Examples

      iex> create_and_verify_visitor(%{field: value})
      {:ok, %Visitor{}}

      iex> create_and_verify_visitor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_and_verify_visitor(attrs \\ %{}) do
    {encoded_token, hashed_token} = Visitor.generate_token()

    visitor = %Visitor{}
    |> Map.put(:token, hashed_token)
    |> Visitor.changeset(attrs)
    |> Repo.insert!()

    url = MakerPassportWeb.Endpoint.url() <> "/verify-email?token=#{encoded_token}"

    Accounts.UserNotifier.confirm_email(visitor, url)

    {:ok, visitor}
  end

  @doc """
  Updates a visitor.

  ## Examples

      iex> update_visitor(%Visitor{}, %{is_verified: true})
      {:ok, %Visitor{}}

      iex> update_visitor(%Visitor{}, %{is_verified: false})
      {:error, %Ecto.Changeset{}}

  """
  def update_visitor(%Visitor{} = visitor, attrs) do
    visitor
    |> Visitor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a visitor and verifies it.

  ## Examples

      iex> update_and_verify_visitor(%Visitor{}, %{field: value})
      {:ok, %Visitor{}}

      iex> update_and_verify_visitor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_and_verify_visitor(%Visitor{} = visitor, attrs \\ %{}) do
    {encoded_token, hashed_token} = Visitor.generate_token()
    attrs = Map.put(attrs, "token", hashed_token)

    {:ok, visitor} = update_visitor(visitor, attrs)

    url = MakerPassportWeb.Endpoint.url() <> "/verify-email?token=#{encoded_token}"

    Accounts.UserNotifier.confirm_email(visitor, url)

    {:ok, visitor}
  end

  @doc """
  List unverified visitors.

  ## Examples

      iex> list_unverified_visitors()
      [%Visitor{}, ...]

  """
  def list_visitors() do
    Visitor
    |> order_by([v], asc: v.is_verified)
    |> Repo.all()
  end

  @doc """
  Creates a email.

  ## Examples

      iex> create_email(%{field: value})
      {:ok, %Email{}}

      iex> create_email(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_email(attrs \\ %{}) do
    %Email{}
    |> Email.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Get emails by visitor id.

  ## Examples

      iex> get_emails_by_visitor_id(visitor_id)
      [%Email{}, ...]

  """
  def list_emails_of_a_visitor(visitor_id) do
    Repo.all(from e in Email, where: e.visitor_id == ^visitor_id)
    |> Repo.preload([profile: [:user]])
  end

  @doc """
  Delete emails by visitor id.

  ## Examples

      iex> delete_emails_of_a_visitor(visitor_id)
      [%Email{}, ...]

  """
  def delete_emails_of_a_visitor(visitor_id) do
    Repo.delete_all(from e in Email, where: e.visitor_id == ^visitor_id)
  end
end
