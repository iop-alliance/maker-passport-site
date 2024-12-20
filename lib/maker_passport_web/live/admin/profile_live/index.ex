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

  @impl true
  def handle_event("send-verification-email", %{"visitor_id" => visitor_id}, socket) do
    visitor = Visitor.get_visitor!(visitor_id)
    {:ok, _} = Visitor.update_and_verify_visitor(visitor)

    {:noreply, socket |> put_flash(:info, "We have sent an email link to #{visitor.email}.")}
  end

  def fetch_subject(socket, _params) do
    socket.assigns.current_user
  end
end
