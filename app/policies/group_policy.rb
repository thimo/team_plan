# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_GROUPS)
  end

  def create?
    @user.role?(Role::BEHEER_GROUPS)
  end

  def show?
    index?
  end

  def update?
    index?
  end

  def destroy?
    @user.role?(Role::BEHEER_GROUPS) && @record.persisted?
  end

  def modify_members?
    @record.persisted? && @record.memberable_via_type.blank?
  end

  def modify_roles?
    @user.role?(Role::BEHEER_ROLES)
  end

  def set_memberable_via_type?
    create? && @record.new_record?
  end

  def permitted_attributes
    attributes = [:name]
    attributes << { member_ids: [] } if modify_members?
    attributes << { role_ids: [] } if modify_roles?
    attributes << :memberable_via_type if set_memberable_via_type?
    attributes
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?(Role::BEHEER_GROUPS)

      scope.none
    end
  end
end
