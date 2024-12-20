defmodule MakerPassportWeb.Admin.ProfileLive.Index do
  use MakerPassportWeb, :live_view

  on_mount {MakerPassportWeb.UserAuth, :mount_current_user}
  alias MakerPassport.Maker

  use Permit.Phoenix.LiveView,
    authorization_module: MakerPassport.Authorization,
    resource_module: MakerPassport.Profile

  @impl true
  def mount(_params, _session, socket) do
    profiles = Maker.list_profiles()

    socket =
      socket
      |> assign(profiles: profiles)

    {:ok, socket}
  end

  def fetch_subject(socket, _params) do
    socket.assigns.current_user
  end
end
