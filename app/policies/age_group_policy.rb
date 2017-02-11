class AgeGroupPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    return false if @record.archived?

    @user.admin? || @user.club_staff?
  end

  def update?
    create?
  end

  def destroy?
    return false if @record.archived? || @record.active?

    create?
  end

  def show_favorite?
    @user.admin? || @user.club_staff?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
