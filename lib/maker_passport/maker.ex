defmodule MakerPassport.Maker do
  @moduledoc """
  The Maker context.
  """

  import Ecto.Query, warn: false
  alias MakerPassport.Accounts
  alias MakerPassport.Repo

  alias MakerPassport.Maker.{Profile, Skill, ProfileSkill}

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles do
    Repo.all(Profile)
  end

  def list_profiles(criteria) when is_list(criteria) do
    query = from(p in Profile, where: not is_nil(p.name))

    Enum.reduce(criteria, query, fn
      {:sort, %{sort_by: sort_by, sort_order: sort_order}}, query ->
        from q in query, order_by: [{^sort_order, ^sort_by}]

      {:limit, limit}, query ->
        from q in query, limit: ^limit

      {:preload, preload}, query ->
        from q in query, preload: ^preload
    end)
    |> Repo.all()
  end

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile!(id), do: Repo.get!(Profile, id) |> Repo.preload(:user) |> Repo.preload([:skills])

  def get_profile_by_user_id!(user_id) do
    user =
      Accounts.get_user!(user_id)
      |> Repo.preload(:profile)

    Repo.get!(Profile, user.profile.id)
    |> Repo.preload(:user)
    |> Repo.preload([:skills])
  end

  def get_profile_with_skills_by_user_id!(user_id) do
    user =
      Accounts.get_user!(user_id)
      |> Repo.preload(:profile)

    Repo.get!(Profile, user.profile.id)
    |> Repo.preload(:user)
    |> Repo.preload([:skills])
  end



  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(attrs \\ %{}) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a profile.

  ## Examples

      iex> delete_profile(profile)
      {:ok, %Profile{}}

      iex> delete_profile(profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{data: %Profile{}}

  """
  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end

   @doc """
  Returns the list of skills.

  ## Examples

      iex> list_skills()
      [%Skill{}, ...]

  """
  def list_skills do
    Repo.all(Skill)
  end

  @doc """
  Gets a single skill.

  Raises `Ecto.NoResultsError` if the Skill does not exist.

  ## Examples

      iex> get_skill!(123)
      %Skill{}

      iex> get_skill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill!(id), do: Repo.get!(Skill, id)

  @doc """
  Creates a skill.

  ## Examples

      iex> create_skill(%{field: value})
      {:ok, %Skill{}}

      iex> create_skill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill(attrs \\ %{}) do
    %Skill{}
    |> Skill.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill.

  ## Examples

      iex> update_skill(skill, %{field: new_value})
      {:ok, %Skill{}}

      iex> update_skill(skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill(%Skill{} = skill, attrs) do
    skill
    |> Skill.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill.

  ## Examples

      iex> delete_skill(skill)
      {:ok, %Skill{}}

      iex> delete_skill(skill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill(%Skill{} = skill) do
    Repo.delete(skill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill changes.

  ## Examples

      iex> change_skill(skill)
      %Ecto.Changeset{data: %Skill{}}

  """
  def change_skill(%Skill{} = skill, attrs \\ %{}) do
    Skill.changeset(skill, attrs)
  end

  def add_skill(profile, skill_text) when is_binary(skill_text) do
    skill =
      case Repo.get_by(Skill, %{name: skill_text}) do
        nil ->
          %Skill{} |> Skill.changeset(%{name: skill_text}) |> Repo.insert!()

        skill ->
          skill
      end

    add_skill(profile, skill.id)
  end

  def add_skill(%Profile{} = profile, skill_id) do
    add_skill(profile.id, skill_id)
  end

  def add_skill(profile_id, skill_id) do
    ProfileSkill.changeset(%ProfileSkill{}, %{profile_id: profile_id, skill_id: skill_id})
    |> Repo.insert()
  end

  def remove_skill(%Profile{} = profile, skill_id) do
    profile_skill = Repo.get_by(ProfileSkill, %{profile_id: profile.id, skill_id: skill_id})
    Repo.delete(profile_skill)
  end

  def search_skills(""), do: []

  def search_skills(search_text) do
    Repo.all(from s in Skill, where: ilike(s.name, ^"%#{search_text}%"))
  end

  def to_skill_list(skills) do
    skills
    |> Enum.map(&to_skill_tuple/1)
    |> Enum.sort_by(&elem(&1, 0))
  end

  def to_skill_list(skills, profile_id) do
    profile_skills = Repo.all(from ps in ProfileSkill, where: ps.profile_id == ^profile_id)
    skill_ids_to_exclude = Enum.map(profile_skills, & &1.skill_id)
    skills = Enum.reject(skills, &(&1.id in skill_ids_to_exclude))
    skills
    |> Enum.map(&to_skill_tuple/1)
    |> Enum.sort_by(&elem(&1, 0))
  end

  defp to_skill_tuple(skill) do
    {skill.name, skill.id}
  end

  def has_skill?(profile, skill_id) do
    # Check if the profile has the skill by querying the database
    Repo.exists?(from s in ProfileSkill,
      where: s.profile_id == ^profile.id and s.skill_id == ^skill_id
    )
  end
end
