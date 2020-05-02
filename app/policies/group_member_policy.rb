class GroupMemberPolicy < ApplicationPolicy
  def create?
    return false if @record&.memberable&.archived? || @record&.group&.archived?

    @user.role?(Role::BEHEER_GROUPS, @record.memberable) || @user.role?(Role::GROUP_MEMB_CREATE, @record.memberable)
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def permitted_attributes
    attributes = [:description]
    attributes << :member_id if @record.new_record?
    attributes
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?(Role::BEHEER_GROUPS)

      scope.active
    end
  end
end
