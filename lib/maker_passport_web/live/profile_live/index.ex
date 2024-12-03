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
        nil -> Maker.list_profiles()
        user ->
          Maker.list_profiles()
          |> Enum.reject(fn profile -> profile.user && profile.user.id == user.id end)
      end

    socket = stream(socket, :profiles, profiles)
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Profile")
    |> assign(:profile, Maker.get_profile!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Profile")
    |> assign(:profile, %Profile{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Profiles")
    |> assign(:search_skills, [])
    |> assign(:profile, nil)
  end

  @impl true
  def handle_info({MakerPassportWeb.ProfileLive.FormComponent, {:saved, profile}}, socket) do
    {:noreply, stream_insert(socket, :profiles, profile)}
  end

  @impl true
  def handle_info({:typeahead, {name, _}, _}, socket) do
    socket =
      socket
      |> update(:search_skills, fn skills -> [name | skills] end)

    profiles =
      case socket.assigns.current_user do
        nil -> Maker.list_profiles(socket.assigns.search_skills)
        user ->
          Maker.list_profiles(socket.assigns.search_skills)
          |> Enum.reject(fn profile -> profile.user && profile.user.id == user.id end)
      end

    {:noreply, stream(socket, :profiles, profiles)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    profile = Maker.get_profile!(id)
    {:ok, _} = Maker.delete_profile(profile)

    {:noreply, stream_delete(socket, :profiles, profile)}
  end

  def handle_event("remove-skill", %{"skill_name" => skill_name}, socket) do
    updated_skills = Enum.filter(socket.assigns.search_skills, fn skill -> skill != skill_name end)
    profiles =
      case socket.assigns.current_user do
        nil -> Maker.list_profiles(updated_skills)
        user ->
          Maker.list_profiles(updated_skills)
          |> Enum.reject(fn profile -> profile.user && profile.user.id == user.id end)
      end
    {:noreply, stream(socket, :profiles, profiles) |> assign(:search_skills, updated_skills)}
  end

  defp remove_selected_skill(skills, selected_skills) do
    Enum.filter(skills, fn {skill, _} -> skill not in selected_skills end)
  end
end
