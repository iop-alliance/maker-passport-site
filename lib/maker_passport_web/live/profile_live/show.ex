defmodule MakerPassportWeb.ProfileLive.Show do
  use MakerPassportWeb, :live_view

  import MakerPassportWeb.CustomComponents
  import MakerPassportWeb.ProfileLive.TypeaheadComponent, only: [typeahead: 1]

  alias MakerPassport.Repo
  alias MakerPassport.Maker
  alias MakerPassport.Maker.Skill

  @impl true
  def mount(_params, session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    profile = Maker.get_profile!(id)
    skills = ordered_skills(profile)

    socket =
      socket
      |> assign(:profile, profile)
      |> assign(:skills, skills)
      |> assign(:page_title, page_title(socket.assigns.live_action))

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
  end

  defp apply_action(socket, :edit_profile, _params) do
    socket
    |> assign_new(:form, fn ->
      to_form(Maker.change_profile(socket.assigns.profile))
    end)
    |> assign_new(:skills_form, fn ->
      to_form(Skill.changeset(%Skill{}))
    end)
    |> assign(:page_title, "Edit Profile")
  end

  defp ordered_skills(profile) do
    profile.skills |> Enum.sort_by(& &1.name)
  end

  @impl true
  def handle_info({:typeahead, {skill_name, _}}, socket) do
    socket =
      socket
      |> push_event("set-input-value", %{id: "skills-picker", label: skill_name})
    {:noreply, socket}
  end

  @impl true
  def handle_event("save_skill", %{"search-field" => skill_name}, socket) do
    save_skill(socket, skill_name, socket.assigns.profile)
    {:noreply, push_navigate(socket, to: ~p"/profiles/#{socket.assigns.profile.id}/edit-profile")}
  end

  def handle_event("remove-skill", %{"skill_id" => skill_id}, socket) do
    remove_skill(socket, String.to_integer(skill_id), socket.assigns.profile)
    {:noreply, push_navigate(socket, to: ~p"/profiles/#{socket.assigns.profile.id}/edit-profile")}
  end

  defp save_skill(socket, skill_name, profile) do
    skill = check_or_create_skill(skill_name)
    add_or_update_skill(socket, skill, profile)
    assign(socket, :profile, profile)
    {:noreply, socket}
  end

  defp add_or_update_skill(socket, skill, profile) do
    if Maker.has_skill?(profile, skill.id) do
      socket
    else
      Maker.add_skill(profile, skill.id)
      socket
    end
  end

  defp check_or_create_skill(skill_name) do
    case Repo.get_by(Skill, name: skill_name) do
      nil ->
        %Skill{name: skill_name}
        |> Skill.changeset()
        |> Repo.insert!()

      skill ->
        skill
    end
  end

  defp remove_skill(socket, skill_id, profile) do
    Maker.remove_skill(profile, skill_id)
    socket
  end

  defp page_title(:show), do: "Show Profile"
  defp page_title(:edit_profile), do: "Edit Profile"
end
