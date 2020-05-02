class KeeperPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::KEEPER_SHOW)
  end

  class Scope < Scope
    def resolve
      return scope if @user.admin?

      scope.none
    end
  end
end
