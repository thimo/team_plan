# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  def index?
    @user.role?(:beheer_vereniging) || @user.role?(:beheer_applicatie)
  end

  def create?
    @user.role?(:beheer_applicatie)
  end

  def show?
    index?
  end

  def update?
    index?
  end

  def destroy?
    @user.role?(:beheer_applicatie) && @record.persisted?
  end

  def modify_roles?
    @user.role?(:beheer_applicatie)
  end

  def set_memberable_via_type?
    @user.role?(:beheer_applicatie)
  end

  def permitted_attributes
    attributes = [:name, member_ids: [], role_ids: []]
    attributes << { role_ids: [] } if modify_roles?
    attributes
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?(:beheer_applicatie)
      scope.none
    end
  end
end
