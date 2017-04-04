class UserPolicy < AdminPolicy
  def resend_password?
    @record.persisted? && @user.admin?
  end
end
