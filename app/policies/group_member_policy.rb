# frozen_string_literal: true

class GroupMemberPolicy < ApplicationPolicy
  def create?
    return false if @record&.memberable&.archived?

    @user.role?(:beheer_vereniging)
  end

  def destroy?
    @user.role?(:beheer_vereniging)
  end

  def permitted_attributes
    attributes = [:group_id, :member_id, :memberable_type, :memberable_id]
    attributes
  end

  class Scope < Scope
    def resolve
      false
    end
  end
end
