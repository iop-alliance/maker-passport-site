defmodule MakerPassportWeb.ProfileLive.Show do
  use MakerPassportWeb, :live_view

  alias MakerPassport.Maker

  import MakerPassportWeb.CustomComponents

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    profile = Maker.get_profile_by_user_id!(user.id)

    socket =
      socket
      |> assign(:user_id, user.id)
      |> assign_new(:form, fn ->
        to_form(Maker.change_profile(profile))
      end)
    {:ok, socket}

  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    profile = Maker.get_profile!(id)

    socket
      = socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:profile, profile)
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Profile"
  defp page_title(:edit_profile), do: "Edit Profile"
end
