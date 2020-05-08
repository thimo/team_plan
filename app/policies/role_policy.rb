class RolePolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_ROLES)
  end

  def create?
    index?
  end

  def show?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index? && @record.persisted?
  end

  def modify_groups?
    index? && @record.persisted?
  end

  def permitted_attributes
    attributes = [:name, :body]
    attributes << {group_ids: []} if modify_groups?
    attributes
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?(Role::BEHEER_ROLES)

      scope.none
    end
  end
end
