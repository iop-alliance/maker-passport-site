defmodule MakerPassport.Maker do
  @moduledoc """
  The Maker context.
  """

  import Ecto.Query, warn: false
  alias MakerPassport.Accounts
  alias MakerPassport.Repo

  alias MakerPassport.Maker.{Certification, Profile, ProfileSkill, Skill, Website, Location}

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles(filter_params \\ %{}) do
    query =
    Profile
    |> join(:left, [p], s in assoc(p, :skills))
    |> join(:left, [p], l in assoc(p, :location))
    |> maybe_filter_by_country(filter_params)
    |> maybe_filter_by_city(filter_params)
    |> maybe_filter_by_skills(filter_params)
    |> preload([:skills, :user])
    |> distinct([p], p.id)

    Repo.all(query)
  end

  defp maybe_filter_by_skills(query, %{search_skills: skills}) when skills != [], do:
    query
    |> where([p, s], s.name in ^skills)
    |> group_by([p], p.id)
    |> having([p, s], count(s.id) == ^length(skills))

  defp maybe_filter_by_skills(query, _), do: query

  def maybe_filter_by_city(query, %{city_search: city}) when city != "" do
    query
    |> where([p, s, l], ilike(l.city, ^"%#{city}%"))
  end

  def maybe_filter_by_city(query, _), do: query

  def maybe_filter_by_country(query, %{country_search: country}) when country != "" do
    query
    |> where([p, s, l], ilike(l.country, ^"%#{country}%"))
  end

  def maybe_filter_by_country(query, _), do: query

  def list_profiles_by_criteria(criteria) when is_list(criteria) do
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
    |> Repo.preload([:user])
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
  def get_profile!(id),
    do:
      Repo.get!(Profile, id)
      |> Repo.preload(:user)
      |> Repo.preload([:skills])
      |> Repo.preload(:certifications)
      |> Repo.preload(:websites)

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
  Create %Location{} or get %Location{}.

  ## Examples

      iex> get_or_create_location("Uk", "London")
      %Location{}

  """
  def get_or_create_location(country, city) do
    case Repo.one(from l in Location, where: ilike(l.country, ^country) and ilike(l.city, ^city)) do
      nil ->
        %Location{country: country, city: city}
        |> Location.changeset()
        |> Repo.insert!()

      location ->
        location
    end
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
    Repo.exists?(
      from s in ProfileSkill,
        where: s.profile_id == ^profile.id and s.skill_id == ^skill_id
    )
  end

  def search_cities(""), do: []

  def search_cities(search_text) do
    Repo.all(from l in Location, where: ilike(l.city, ^"%#{search_text}%"))
  end

  def search_cities("", _), do: []

  def search_cities(search_text, country) do
    Repo.all(from l in Location, where: ilike(l.city, ^"%#{search_text}%") and l.country == ^country)
  end

  def to_city_list(cities, selected_city) when is_binary(selected_city) do
    cities = Enum.filter(cities, &(&1.city != selected_city))

    cities
    |> Enum.map(&to_city_tuple/1)
    |> Enum.sort_by(&elem(&1, 0))
  end

  def to_city_list(cities, location_id) do
    cities = Enum.filter(cities, &(&1.id != location_id))

    cities
    |> Enum.map(&to_city_tuple/1)
    |> Enum.sort_by(&elem(&1, 0))
  end

  defp to_city_tuple(location) do
    {location.city, location.id}
  end

  def search_countries(""), do: []

  def search_countries(search_text) do
    Repo.all(from c in Location, where: ilike(c.country, ^"%#{search_text}%"), distinct: c.country)
  end

  def to_country_list(countries, selected_country) do
    countries = Enum.filter(countries, &(&1.country != selected_country))

    countries
    |> Enum.map(&to_country_tuple/1)
    |> Enum.sort_by(&elem(&1, 0))
  end

  defp to_country_tuple(country) do
    {country.country, country.id}
  end

  @doc """
  Gets a single website.

  Raises `Ecto.NoResultsError` if the Website does not exist.

  ## Examples

      iex> get_website!(123)
      %Website{}

      iex> get_website!(456)
      ** (Ecto.NoResultsError)

  """
  def get_website!(id), do: Repo.get!(Website, id)

  @doc """
  Creates a website,

  ## Examples

      iex> create_website(%{field: value})
      {:ok, %Website{}}

      iex> create_website(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_website(attrs \\ %{}) do
    %Website{}
    |> Website.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a website.

  ## Examples

      iex> update_website(website, %{field: new_value})
      {:ok, %Website{}}

      iex> update_website(website, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_website(%Website{} = website, attrs) do
    website
    |> Website.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a website.

  ## Examples

      iex> delete_website(website)
      {:ok, %Website{}}

      iex> delete_website(website)
      {:error, %Ecto.Changeset{}}

  """
  def delete_website(%Website{} = website) do
    Repo.delete(website)
  end

  def remove_website(website_id) do
    website = get_website!(website_id)
    Repo.delete(website)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking website changes.

  ## Examples

      iex> change_website(website)
      %Ecto.Changeset{data: %Website{}}

  """
  def change_website(%Website{} = website, attrs \\ %{}) do
    Website.changeset(website, attrs)
  end

  def add_website(profile_id, website_params) do
    website_params = Map.put(website_params, "profile_id", profile_id)
    create_website(website_params)
  end

  @doc """
  Gets a single certification.

  Raises `Ecto.NoResultsError` if the Certification does not exist.

  ## Examples

      iex> get_certification!(123)
      %Certification{}

      iex> get_certification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_certification!(id), do: Repo.get!(Certification, id)

  @doc """
  Creates a certification,

  ## Examples

      iex> create_certification(%{field: value})
      {:ok, %Certification{}}

      iex> create_certification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_certification(attrs \\ %{}) do
    %Certification{}
    |> Certification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a certification.

  ## Examples

      iex> delete_certification(certification)
      {:ok, %Certification{}}

      iex> delete_certification(certification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_certification(%Certification{} = certification) do
    Repo.delete(certification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking certification changes.

  ## Examples

      iex> change_certification(certification)
      %Ecto.Changeset{data: %Certification{}}

  """
  def change_certification(%Certification{} = certification, attrs \\ %{}) do
    Certification.changeset(certification, attrs)
  end

  def add_certification(profile_id, certification_params) do
    certification_params = Map.put(certification_params, "profile_id", profile_id)
    create_certification(certification_params)
  end

  def remove_certification(certification_id) do
    certification = get_certification!(certification_id)
    Repo.delete(certification)
  end
end
