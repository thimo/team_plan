class IntranetPolicy < ApplicationPolicy
  # TODO: change to correct access level

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
      return scope if @user.admin?

      scope.none
    end
  end
end
