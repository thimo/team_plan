class OrgPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    index?
  end

  def show_members?
    true
  end

  def show_seasons?
    true
  end

  def show_local_teams?
    @user.admin?
  end

  def show_comments?
    @user.admin?
  end

  class Scope < Scope
    def resolve
      return scope if @user.admin?

      scope.none
    end
  end
end
