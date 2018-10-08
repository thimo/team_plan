# frozen_string_literal: true

class PlayerEvaluationPolicy < ApplicationPolicy
  def index?
    @user.admin? ||
      @user.role?(Role::MEMBER_SHOW_EVALUATIONS, @record) ||
      @user.team_staff_for?(@record)
  end

  def show?
    @user.admin? ||
      @user.role?(Role::MEMBER_SHOW_EVALUATIONS, @record) ||
      @user.team_staff_for?(@record)
  end

  def create?
    return false unless @record.team_evaluation.active?

    @user.admin? || @user.role?(Role::MEMBER_CREATE_EVALUATIONS, @record)
  end

  def update?
    return false if @record.team_evaluation.finished_at.blank?

    create?
  end

  def destroy?
    return false if @record.team_evaluation.finished_at.blank?

    @user.admin? || @user.role?(Role::MEMBER_CREATE_EVALUATIONS, @record)
  end

  class Scope < Scope
    def resolve
      # TODO: This will probably not work for coordinators
      if user.admin? || @user.role?(Role::MEMBER_SHOW_EVALUATIONS, @record)
        scope.all.finished
      else
        scope.public_or_as_team_staff(user).finished
      end
    end
  end
end
