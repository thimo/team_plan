class UserPolicy < AdminPolicy
  def resend_password?
    @record.persisted? && @user.admin?
  end

  def impersonate?
    @user.admin?
  end

  def stop_impersonating?
    true
  end
end
