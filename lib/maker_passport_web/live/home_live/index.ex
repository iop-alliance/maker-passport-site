defmodule MakerPassportWeb.HomeLive.Index do
  use MakerPassportWeb, :live_view

  on_mount {MakerPassportWeb.UserAuth, :mount_current_user}

  import Ecto.Query, warn: false

  alias MakerPassport.Maker

  @impl true
  def mount(_params, _session, socket) do
    latest_profiles = fetch_latest_profiles(socket.assigns.current_user)

    socket =
      socket
      |> assign(latest_profiles: latest_profiles)

    {:ok, socket}
  end

  defp fetch_latest_profiles(nil) do
    Maker.list_profiles_by_criteria(
      limit: 4,
      sort: %{sort_by: :updated_at, sort_order: :desc},
      preload: [:skills]
    )
  end

  defp fetch_latest_profiles(user) do
    Maker.list_profiles_by_criteria(
      limit: 4,
      sort: %{sort_by: :updated_at, sort_order: :desc},
      preload: [:skills],
      current_id: user.id
    )
  end
end
