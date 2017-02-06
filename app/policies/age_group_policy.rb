class AgeGroupPolicy < ApplicationPolicy
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
    @user.admin? && !@record.archived?
  end

  def destroy?
    @user.admin? && !@record.active? && !@record.archived?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
