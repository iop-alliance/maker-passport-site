defmodule MakerPassportWeb.ProfileLive.Index do
  use MakerPassportWeb, :live_view

  on_mount {MakerPassportWeb.UserAuth, :mount_current_user}

  alias MakerPassport.Maker
  alias MakerPassport.Maker.Profile
  import MakerPassportWeb.ProfileLive.TypeaheadComponent, only: [typeahead: 1]
  import MakerPassportWeb.CustomComponents

  @impl true
  def mount(_params, _session, socket) do
    profiles =
      case socket.assigns.current_user do
        nil ->
          Maker.list_profiles()

        user ->
          Maker.list_profiles()
          |> Enum.reject(fn profile -> profile.user && profile.user.id == user.id end)
      end

    socket =
      socket
      |> assign(:page_title, "Maker Profiles")
      |> assign(:search_skills, [])
      |> assign(:no_skills_results, false)
      |> assign(:profile, nil)
      |> stream(:profiles, profiles)
      |> assign(:filter_params, %{search_skills: [], country_search: "", city_search: ""})

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({MakerPassportWeb.ProfileLive.FormComponent, {:saved, profile}}, socket) do
    {:noreply, stream_insert(socket, :profiles, profile)}
  end

  @impl true
  def handle_info({:typeahead, {value, _}, id}, socket) do
    socket =
      socket
      |> push_event(%{id: id, label: value})
      |> update(:filter_params, fn params ->
        add_filter_params(id, params, value)
      end)

    profiles = filter_profiles(socket.assigns.current_user, socket.assigns.filter_params)

    {:noreply, stream(socket, :profiles, profiles)}
  end

  def handle_event("filter-profiles", %{"filter_params" => %{"country_search" => ""}}, socket) do
    handle_remove_search(socket, [:city_search, :country_search])
  end

  def handle_event("filter-profiles", %{"filter_params" => %{"city_search" => ""}}, socket) do
    handle_remove_search(socket, [:city_search])
  end

  def handle_event("remove-country", _params, socket) do
    handle_remove_search(socket, [:city_search, :country_search])
  end

  def handle_event("remove-city", _params, socket) do
    handle_remove_search(socket, [:city_search])
  end

  def handle_event("remove-skill", %{"skill_name" => skill_name}, socket) do
    filter_params = socket.assigns.filter_params
    updated_skills = Enum.filter(filter_params.search_skills, fn skill -> skill != skill_name end)
    filter_params = %{filter_params | search_skills: updated_skills}

    profiles = filter_profiles(socket.assigns.current_user, filter_params)

    {:noreply, stream(socket, :profiles, profiles) |> assign(:filter_params, filter_params)}
  end

  @impl true
  def handle_info({:typeahead, {name, _}, _}, socket) do
    socket =
      socket
      |> update(:search_skills, fn skills -> [name | skills] end)

    profiles =
      case socket.assigns.current_user do
        nil ->
          Maker.list_profiles(socket.assigns.search_skills)

        user ->
          Maker.list_profiles(socket.assigns.search_skills)
          |> Enum.reject(fn profile -> profile.user && profile.user.id == user.id end)
      end

    socket =
      socket
      |> assign(:no_skills_results, profiles == [])
      |> stream(:profiles, profiles)

    {:noreply, socket}
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  defp handle_remove_search(socket, fields) do
    filter_params = Enum.reduce(fields, socket.assigns.filter_params, fn field, acc ->
      Map.put(acc, field, "")
    end)

    profiles = filter_profiles(socket.assigns.current_user, filter_params)
    {:noreply, stream(socket, :profiles, profiles) |> assign(:filter_params, filter_params)}
  end

  defp add_filter_params("country-search-picker", filter_params, value) do
    Map.put(filter_params, :country_search, value)
    |> Map.put(:city_search, "")
  end

  defp add_filter_params("city-search-picker", filter_params, value) do
    Map.put(filter_params, :city_search, value)
  end

  defp add_filter_params("skills-search-picker", filter_params, value) do
    Map.update(filter_params, :search_skills, [value], fn skills -> [value | skills] end)
  end

  defp push_event(socket, %{id: id} = params) when id != "skills-search-picker" do
    push_event(socket, "set-input-value", params)
  end

  defp push_event(socket, _), do: socket

  def filter_profiles(current_user, filter_params) do
    case current_user do
      nil -> Maker.list_profiles(filter_params)
      user ->
        Maker.list_profiles(filter_params)
        |> Enum.reject(fn profile -> profile.user && profile.user.id == user.id end)
    end
  end

  defp remove_selected_skill(skills, selected_skills) do
    Enum.filter(skills, fn {skill, _} -> skill not in selected_skills end)
  end

  def handle_event("remove-skill", %{"skill_name" => skill_name}, socket) do
    updated_skills =
      Enum.filter(socket.assigns.search_skills, fn skill -> skill != skill_name end)

    profiles =
      case socket.assigns.current_user do
        nil ->
          Maker.list_profiles(updated_skills)

        user ->
          Maker.list_profiles(updated_skills)
          |> Enum.reject(fn profile -> profile.user && profile.user.id == user.id end)
      end

    socket =
      socket
      |> assign(:no_skills_results, profiles == [])
      |> assign(:search_skills, updated_skills)
      |> stream(:profiles, profiles)

    {:noreply, socket}
  end

  defp remove_selected_skill(skills, selected_skills) do
    Enum.filter(skills, fn {skill, _} -> skill not in selected_skills end)
  end
end
