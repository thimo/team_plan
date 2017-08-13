class InjuryPolicy < ApplicationPolicy
  def show?
    # Visible for club staff, author, member's team staff, member
    create? || @record.user = @user || @user.has_member?(@record.member)
  end

  def new?
    create?
  end

  def create?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record.member)
  end

  def update?
    create?
  end

  def destroy?
    return false if @record.new_record?

    update?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
