defmodule MakerPassportWeb.VerificationController do
  use MakerPassportWeb, :controller

  alias MakerPassport.Accounts.UserNotifier
  alias MakerPassport.Maker
  def verify_email(conn, %{"token" => token}) do
    visitor = Maker.get_visitor_by_token(token)
    case visitor do
      nil ->
        render(conn, :token_expired, layout: false)
      _ ->
        Maker.update_visitor(visitor, %{is_verified: true})
        emails = Maker.get_emails_by_visitor_id(visitor.id)
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
