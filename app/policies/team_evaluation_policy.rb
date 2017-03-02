class TeamEvaluationPolicy < ApplicationPolicy
  def index?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record)
  end

  def show?
    index?
  end

  def create?
    return false unless @record.active?

    @user.admin? || @user.club_staff?
  end

  def update?
    return false if @record.finished_at.present?

    create? || @user.is_team_staff_for?(@record)
  end

  def destroy?
    return false if @record.new_record? || @record.finished_at.present?

    @user.admin? || @user.club_staff?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
