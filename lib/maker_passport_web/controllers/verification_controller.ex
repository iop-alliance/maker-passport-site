defmodule MakerPassportWeb.VerificationController do
  use MakerPassportWeb, :controller

  alias MakerPassport.Accounts.UserNotifier
  alias MakerPassport.Visitor

  def verify_email(conn, %{"token" => token}) do
    visitor = Visitor.get_visitor_by_token(token)
    case visitor do
      nil ->
        render(conn, :token_expired, layout: false)
      %{is_verified: true} ->
        render(conn, :verified, layout: false)
      _ ->
        Visitor.update_visitor(visitor, %{is_verified: true})
        emails = Visitor.list_emails_of_a_visitor(visitor.id)
        Visitor.delete_emails_of_a_visitor(visitor.id)
        emails |> Enum.each(fn email ->
          email_params = %{
            sender_email: visitor.email,
            maker_email: email.profile.user.email,
            subject: email.subject,
            body: email.body
          }
          UserNotifier.send_email_to_maker(email_params)
        end)
        render(conn, :verified, layout: false)
    end
  end
end
