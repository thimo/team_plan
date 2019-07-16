# frozen_string_literal: true

class OrgPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::ORG_SHOW)
  end

  def show?
    index?
  end

  class Scope < Scope
    def resolve
      return scope if @user.admin?

      scope.none
    end
  end
end
