defmodule MakerPassportWeb.ProfileLive.Index do
  use MakerPassportWeb, :live_view

  alias MakerPassport.Maker
  alias MakerPassport.Maker.Profile

  import MakerPassportWeb.CustomComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :profiles, Maker.list_profiles())}
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
    |> assign(:profile, nil)
  end

  @impl true
  def handle_info({MakerPassportWeb.ProfileLive.FormComponent, {:saved, profile}}, socket) do
    {:noreply, stream_insert(socket, :profiles, profile)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    profile = Maker.get_profile!(id)
    {:ok, _} = Maker.delete_profile(profile)

    {:noreply, stream_delete(socket, :profiles, profile)}
  end
end
