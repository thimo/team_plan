# frozen_string_literal: true

class GroupMemberPolicy < ApplicationPolicy
  def create?
    return false if @record&.memberable&.archived?

    @user.role?(Role::BEHEER_GROUPS)
  end

  def destroy?
    @user.role?(Role::BEHEER_GROUPS)
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?(Role::BEHEER_GROUPS)

      scope.active
    end
  end
end
