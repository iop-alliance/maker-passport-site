defmodule MakerPassportWeb.ProfileLive.EmailFormComponent do
  use MakerPassportWeb, :live_component

  alias MakerPassport.Maker.Email
  alias MakerPassport.Maker
  alias MakerPassport.Accounts.UserNotifier

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle></:subtitle>
      </.header>

      <.simple_form
        for={@email_form}
        id="email-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <%= if !(@current_user) do %>
          <.input field={@email_form[:sender_name]} type="text" label="Sender Name" />
          <.input field={@email_form[:sender_email]} type="email" label="Sender Email" />
        <% end %>
        <.input field={@email_form[:subject]} type="text" label="Subject" />
        <.input field={@email_form[:body]} type="textarea" label="Body" />
        <:actions>
          <.button phx-disable-with="Saving...">Send Email</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign_new(:email_form, fn ->
       to_form(Email.changeset(%Email{}))
     end)
     |> assign(assigns)}
  end

  @impl true
  def handle_event("validate", %{"email" => email_params}, socket) do
    changeset = Email.changeset(%Email{}, email_params)

    {:noreply, assign(socket, :email_form, to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"email" => email_params}, %{assigns: %{current_user: nil}} = socket) do
    case Maker.get_visitor_by_email(email_params["sender_email"]) do
      nil ->
        visitor_params = %{email: email_params["sender_email"], name: email_params["sender_name"]}
        {:ok, visitor} = Maker.create_and_verify_visitor(visitor_params)
        create_email(email_params, visitor, socket)

      %{is_verified: false} = visitor ->
        {:ok, visitor} = Maker.update_and_verify_visitor(visitor, %{"name" => email_params["sender_name"]})
        create_email(email_params, visitor, socket)

      _visitor ->
        email_params = %{
          sender_email: email_params["sender_email"],
          maker_email: socket.assigns.profile.user.email,
          subject: email_params["subject"],
          body: email_params["body"]
        }

        send_email(email_params, socket)
    end
  end

  def handle_event(
        "save",
        %{"email" => email_params},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    email_params = %{
      sender_email: current_user.email,
      maker_email: socket.assigns.profile.user.email,
      subject: email_params["subject"],
      body: email_params["body"]
    }

    send_email(email_params, socket)
  end

  def create_email(email_params, visitor, socket) do
    email_params =
      Map.merge(email_params, %{
        "visitor_id" => visitor.id,
        "profile_id" => socket.assigns.profile.id
      })

    case Maker.create_email(email_params) do
      {:ok, _email} ->
        {:noreply,
         socket
         |> put_flash(:info, "We have sent an email link to verify your email.")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :validate))}
    end
  end

  def send_email(email_params, socket) do
    case UserNotifier.send_email_to_maker(email_params) do
      {:ok, _email} ->
        {:noreply,
         socket
         |> put_flash(:info, "Email sent to maker")
         |> push_navigate(to: socket.assigns.navigate)}
    end
  end
end
