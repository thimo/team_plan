class PlayerEvaluationPolicy < ApplicationPolicy
  def index?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record)
  end

  def show?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record)
  end

  def create?
    return false unless @record.active?

    @user.admin? || @user.club_staff?
  end

  def update?
    return false unless @record.team_evaluation.finished_at.present?

    create?
  end

  def destroy?
    return false unless @record.team_evaluation.finished_at.present?

    @user.admin? || @user.club_staff?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
