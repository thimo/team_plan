class TrainingSchedulePolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record.team)
  end

  def update?
    create?
  end

  def destroy?
    return false if @record.new_record?

    create?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
