class PresencePolicy < ApplicationPolicy
  def update?
    return false if @record.presentable.afgelast?

    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
