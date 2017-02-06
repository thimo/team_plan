class SeasonPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    # Only by admin
    @user.admin?
  end

  def update?
    # Only by admin
    @user.admin? && !@record.archived?
  end

  def destroy?
    # Only by admin
    @user.admin? && !@record.active? && !@record.archived?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
