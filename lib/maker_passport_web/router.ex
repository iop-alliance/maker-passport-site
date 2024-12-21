defmodule MakerPassportWeb.Router do
  use MakerPassportWeb, :router

  import MakerPassportWeb.UserAuth
  @env Application.compile_env(:maker_passport, :env)

  if @env == :dev, do: forward("/mailbox", Plug.Swoosh.MailboxPreview)

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MakerPassportWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MakerPassportWeb do
    pipe_through :browser

    live "/", HomeLive.Index, :index
    live "/profiles", ProfileLive.Index

    get "/about", PageController, :about
    live "/verify-email", VisitorLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", MakerPassportWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:maker_passport, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MakerPassportWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", MakerPassportWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{MakerPassportWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  # Separate admin routes
  scope "/admin", MakerPassportWeb.Admin do
    pipe_through [:browser, :require_authenticated_user]

    live_session :admin_user,
      on_mount: [
        {MakerPassportWeb.UserAuth, :ensure_authenticated},
        {Permit.Phoenix.LiveView.AuthorizeHook, []}
      ] do
      live "/visitors", VisitorLive.Index, :index
      live "/profiles", ProfileLive.Index, :index
    end
  end

  scope "/", MakerPassportWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{MakerPassportWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      # live "/profiles/new", ProfileLive.Index, :new

      # live "/profiles/me", ProfileLive.MyProfile
      # live "/profiles/me/edit", ProfileLive.MyProfile, :edit
      live "/profiles/:id/edit-profile", ProfileLive.Show, :edit_profile
      # live "/profiles/:id/edit", ProfileLive.Index, :edit
      # live "/profiles/:id/show/edit", ProfileLive.Show, :edit
    end
  end

  scope "/", MakerPassportWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{MakerPassportWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new

      live "/profiles/:id/contact", ProfileLive.Show, :contact
      live "/profiles/:id", ProfileLive.Show, :show
    end
  end
end
