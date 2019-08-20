# frozen_string_literal: true

class KeeperPolicy < ApplicationPolicy
  def index?
    true || @user.admin? || @user.role?(Role::KEEPER_SHOW)
  end

  class Scope < Scope
    def resolve
      return scope if @user.admin?

      scope.none
    end
  end
end
