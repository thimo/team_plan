class TeamMemberPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    return false if @record.archived?

    @user.admin? || @user.club_staff?
  end

  def update?
    create? || @user.is_team_staff_for?(@record)
  end

  def set_role?
    @user.admin? || @user.club_staff?
  end

  def destroy?
    return true if @record.active? && @user.admin? # Admin can always remove team members in an active season
    return false if @record.archived? || @record.active?

    @user.admin? || @user.club_staff?
  end

  def show_status?
    return false if @record.status == @record.team.status

    @user.admin? || @user.club_staff?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
