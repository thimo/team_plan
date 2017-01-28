class AdminPolicy < ApplicationPolicy
  def index?
    @user.role_admin?
  end

  def create?
    @user.role_admin?
  end

  def show?
    @user.role_admin?
  end

  def update?
    @user.role_admin?
  end

  def destroy?
    @user.role_admin?
  end

  class Scope < Scope
    def resolve
      scope if @user.role_admin?
    end
  end
end
