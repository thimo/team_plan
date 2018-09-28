# frozen_string_literal: true

class GroupMemberPolicy < ApplicationPolicy
  def create?
    return false if @record&.memberable&.archived?

    @user.role?(Role::BEHEER_VERENIGING)
  end

  def destroy?
    @user.role?(Role::BEHEER_VERENIGING)
  end

  class Scope < Scope
    def resolve
      false
    end
  end
end
