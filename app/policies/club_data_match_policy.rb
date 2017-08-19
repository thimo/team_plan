class ClubDataMatchPolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record)
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
