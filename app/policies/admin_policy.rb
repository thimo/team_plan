class AdminPolicy < ApplicationPolicy
  def index?
    @user.admin?
  end

  def create?
    @user.admin?
  end

  def show?
    @user.admin?
  end

  def update?
    @user.admin?
  end

  def destroy?
    @user.admin? && @record.persisted?
  end

  class Scope < Scope
    def resolve
      scope if @user.admin?
    end
  end
end
