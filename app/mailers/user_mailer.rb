class UserMailer < ApplicationMailer
  def new_account_notification(user, generated_password)
    @user = user
    @generated_password = generated_password
    mail(from: default_from, to: @user.email_with_name, subject: "Account aangemaakt")
  end

  def password_reset(user, generated_password)
    @user = user
    @generated_password = generated_password
    mail(from: default_from, to: @user.email_with_name, subject: "Nieuw wachtwoord")
  end
end
