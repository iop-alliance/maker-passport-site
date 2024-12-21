defmodule MakerPassportWeb.VisitorLive do
  use MakerPassportWeb, :live_view

  alias MakerPassport.Accounts.UserNotifier
  alias MakerPassport.Visitor

  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token}, as: "visitor")

    {:ok, assign(socket, form: form)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">Confirm Account</.header>

      <.simple_form for={@form} id="confirmation_form" phx-submit="confirm_account">
        <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
        <:actions>
          <.button phx-disable-with="Confirming..." class="w-full">Confirm my account</.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/users/register"}>Register</.link>
        | <.link href={~p"/users/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def handle_event("confirm_account", %{"visitor" => %{"token" => token}}, socket) do
    case Visitor.get_visitor_by_token(token) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "Confirmation link is invalid or it has expired.")
         |> redirect(to: ~p"/")}

      %{is_verified: true} ->
        {:noreply, socket |> redirect(to: ~p"/")}

      visitor ->
        {:ok, _updated_visitor} = Visitor.update_visitor(visitor, %{is_verified: true})

        # Process emails
        emails = Visitor.list_emails_of_a_visitor(visitor.id)
        Visitor.delete_emails_of_a_visitor(visitor.id)

        # Send emails to makers
        emails
        |> Enum.each(fn email ->
          email_params = %{
            sender_email: visitor.email,
            maker_email: email.profile.user.email,
            subject: email.subject,
            body: email.body
          }

          UserNotifier.send_email_to_maker(email_params)
        end)

        {:noreply,
         socket
         |> put_flash(:info, "All you pending emails have been sent to makers.")
         |> redirect(to: ~p"/")}
    end
  end
end
