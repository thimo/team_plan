class TeamMemberPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    @user.admin?
  end

  def update?
    return false if @record.archived?

    @user.admin?
  end

  def destroy?
    return false if @record.archived? || @record.active

    @user.admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
