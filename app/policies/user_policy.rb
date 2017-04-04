class UserPolicy < AdminPolicy
  def resend_password?
    @user.admin?
  end
end
