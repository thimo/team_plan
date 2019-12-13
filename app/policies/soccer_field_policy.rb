class SoccerFieldPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_SOCCER_FIELDS)
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

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
