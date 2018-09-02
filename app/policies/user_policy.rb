# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    @user.role?(:beheer_applicatie)
  end

  def create?
    index?
  end

  def show?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index? && @record.persisted?
  end

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

  class Scope < Scope
    def resolve
      scope.all if @user.role?(:beheer_applicatie)
    end
  end
end
