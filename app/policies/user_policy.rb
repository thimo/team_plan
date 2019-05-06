# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_USERS)
  end

  def create?
    @user.role?(Role::USER_CREATE)
  end

  def show?
    @user.role?(Role::USER_SHOW)
  end

  def update?
    create?
  end

  def destroy?
    create? && @record.persisted?
  end

  def update_settings?
    @record == @user
  end

  def resend_password?
    @record.persisted? && create?
  end

  def impersonate?
    @user.role?(Role::USER_IMPERSONATE)
  end

  def stop_impersonating?
    true
  end

  def set_role?
    @user.admin?
  end

  def permitted_attributes
    attributes = [:first_name, :middle_name, :last_name, :email]
    attributes << :role if set_role?
    attributes
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?(Role::BEHEER_USERS)

      scope.none
    end
  end
end
