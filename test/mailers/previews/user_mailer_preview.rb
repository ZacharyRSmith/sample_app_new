# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  # or: http://my-marvelous-macaroni-106113.nitrousapp.com:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first
    user.activation_token = User.new_token
    UserMailer.account_activation(user)
  end

  # Preview this email at:
  # http://my-marvelous-macaroni-106113.nitrousapp.com:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    user.password_reset_token = User.new_token
    UserMailer.password_reset(user)
  end

end