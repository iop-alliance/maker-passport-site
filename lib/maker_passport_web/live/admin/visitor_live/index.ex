defmodule MakerPassportWeb.Admin.VisitorLive.Index do
  use MakerPassportWeb, :live_view

  on_mount {MakerPassportWeb.UserAuth, :mount_current_user}
  alias MakerPassport.Visitor

  use Permit.Phoenix.LiveView,
    authorization_module: MakerPassport.Authorization,
    resource_module: MakerPassport.Visitors.Visitor

  @impl true
  def mount(_params, _session, socket) do
    pending_visitors = Visitor.list_unverified_visitors()

    socket =
      socket
      |> assign(pending_visitors: pending_visitors)

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
