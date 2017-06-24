class TeamActionPolicy < ApplicationPolicy
  def new?
    create?
  end

  def create?
    @user.admin? || @user.club_staff?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
