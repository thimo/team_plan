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
    return false if @record.archived?
    
    # Only by admin
    @user.admin?
  end

  def destroy?
    return false if @record.archived? || @record.active?

    # Only by admin
    @user.admin?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
