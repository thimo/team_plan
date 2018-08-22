# frozen_string_literal: true

class UserPolicy < AdminPolicy
  def update_settings?
    @record == @user
  end

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
