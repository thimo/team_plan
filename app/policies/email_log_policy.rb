class EmailLogPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_EMAIL_LOG)
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
      return scope.all if @user.role?(Role::BEHEER_EMAIL_LOG)

      scope.none
    end
  end
end
