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
    create?
  end

  def destroy?
    return false if @record.archived? || @record.active?

    @user.admin? || @user.club_staff?
  end

  def show_private_data?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_member_for?(@record)
  end

  def show_comments?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record) ||
    @user.has_member?(@record.member)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
