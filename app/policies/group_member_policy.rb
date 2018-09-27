# frozen_string_literal: true

class GroupMemberPolicy < ApplicationPolicy
  def create?
    return false if @record&.memberable&.archived?

    @user.role?(:beheer_vereniging)
  end

  def destroy?
    @user.role?(:beheer_vereniging)
  end

  class Scope < Scope
    def resolve
      false
    end
  end
end
