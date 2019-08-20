# frozen_string_literal: true

class TeamEvaluationPolicy < ApplicationPolicy
  def index?
    @user.admin? ||
      @user.role?(Role::TEAM_SHOW_EVALUATIONS, @record) ||
      @user.team_staff_for?(@record)
  end

  def show?
    index?
  end

  def create?
    return false if @record.team.nil? || !@record.team.active?

    @user.role?(Role::TEAM_CREATE_EVALUATIONS, @record)
  end

  def update?
    return false if @record.finished_at.present?

    create? || @user.team_staff_for?(@record)
  end

  def destroy?
    return false if @record.new_record? || @record.finished_at.present?

    @user.role?(Role::TEAM_CREATE_EVALUATIONS, @record)
  end

  def send_invite?
    return false if @record.invited_at.present?

    @user.role?(Role::TEAM_CREATE_EVALUATIONS, @record)
  end

  def finish_evaluation?
    return false if @record.new_record? || @record.finished_at.present?

    update?
  end

  def re_open?
    return false if @record.archived? || @record.new_record? || @record.finished_at.nil?

    @user.role?(Role::TEAM_CREATE_EVALUATIONS, @record)
  end

  class Scope < Scope
    def resolve
      # TODO: This will probably not work for coordinators
      if @user.role?(Role::TEAM_CREATE_EVALUATIONS, @record)
        scope.all
      else
        scope.invited
      end
    end
  end
end
