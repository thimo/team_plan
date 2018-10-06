# frozen_string_literal: true

class PlayerEvaluationPolicy < ApplicationPolicy
  def index?
    @user.admin? ||
      @user.club_staff_for?(@record) ||
      @user.team_staff_for?(@record)
  end

  def show?
    @user.admin? ||
      @user.club_staff_for?(@record) ||
      @user.team_staff_for?(@record)
  end

  def create?
    return false unless @record.team_evaluation.active?

    @user.admin? || @user.club_staff_for?(@record)
  end

  def update?
    return false if @record.team_evaluation.finished_at.blank?

    create?
  end

  def destroy?
    return false if @record.team_evaluation.finished_at.blank?

    @user.admin? || @user.club_staff_for?(@record)
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.club_staff?
        scope.all.finished
      else
        scope.public_or_as_team_staff(user).finished
      end
    end
  end
end
