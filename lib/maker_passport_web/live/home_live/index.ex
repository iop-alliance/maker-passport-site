defmodule MakerPassportWeb.HomeLive.Index do
  use MakerPassportWeb, :live_view

  on_mount {MakerPassportWeb.UserAuth, :mount_current_user}

  import Ecto.Query, warn: false

  alias MakerPassport.Maker

  @impl true
  def mount(_params, _session, socket) do
    latest_profiles =
      Maker.list_profiles(
        limit: 4,
        sort: %{sort_by: :updated_at, sort_order: :desc},
        preload: [:skills]
      )

    socket =
      socket
      |> assign(latest_profiles: latest_profiles)

    {:ok, socket}
  end
end
