defmodule MakerPassport.Accounts.UserNotifier do
  @moduledoc false
  import Swoosh.Email

  alias MakerPassport.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, reply_to, subject, body) do
    email =
      new()
      |> to(recipient)
      |> reply_to(reply_to)
      |> from({"IOP: Maker Passport", "no-reply@internetofproduction.org"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"IOP: Maker Passport", "no-reply@internetofproduction.org"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email,
      "Maker Passport account confirmation instructions",
      """

      ==============================

      Hi #{user.email},

      You can confirm your account by visiting the URL below:

      #{url}

      If you didn't create an account with us, please ignore this.

      ==============================
      """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end


  @doc """
  Deliver instructions to update a user email.
  """
  def confirm_email(visitor, url) do
    deliver(visitor.email, "Confirm email", """

    ==============================

    Hi #{visitor.name},

    You can confirm your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def send_email_to_maker(email_params) do
    deliver(email_params.maker_email, email_params.sender_email, email_params.subject, email_params.body)
  end
end
