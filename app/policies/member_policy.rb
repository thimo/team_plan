class MemberPolicy < ApplicationPolicy
  # TODO limit to proper context
  def index?
    true
  end

  # TODO limit to proper context
  def show?
    true
  end

  class Scope < Scope
    def resolve
      scope if @user.admin?
    end
  end
end
