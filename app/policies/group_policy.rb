# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_GROUPS) || @user.role?(Role::GROUP_SHOW)
  end

  def show?
    index?
  end

  def create?
    @user.role?(Role::BEHEER_GROUPS) || @user.role?(Role::GROUP_CREATE)
  end

  def update?
    create?
  end

  def destroy?
    create? && @record.persisted?
  end

  def modify_members?
    @record.persisted? && @record.memberable_via_type.blank?
  end

  def set_memberable_via_type?
    create? && @record.new_record?
  end

  def permitted_attributes
    attributes = [:name]
    attributes << { member_ids: [] } if modify_members?
    attributes << :memberable_via_type if set_memberable_via_type?
    attributes
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?(Role::BEHEER_GROUPS)

      scope.active
    end
  end
end
