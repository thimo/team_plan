# frozen_string_literal: true

class TeamEvaluationPolicy < ApplicationPolicy
  def index?
    @user.admin? ||
      @user.club_staff_for?(@record) ||
      @user.team_staff_for?(@record)
  end

  def show?
    index?
  end

  def create?
    return false if @record.team.nil? || !@record.team.active?

    @user.admin? || @user.club_staff_for?(@record)
  end

  def update?
    return false if @record.finished_at.present?

    create? || @user.team_staff_for?(@record)
  end

  def destroy?
    return false if @record.new_record? || @record.finished_at.present?

    @user.admin? || @user.club_staff_for?(@record)
  end

  def send_invite?
    return false if @record.invited_at.present?

    @user.admin? || @user.club_staff_for?(@record)
  end

  def finish_evaluation?
    return false if @record.new_record? || @record.finished_at.present?

    update?
  end

  def re_open?
    return false if @record.archived? || @record.new_record? || @record.finished_at.nil?

    @user.admin? || @user.club_staff_for?(@record)
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.club_staff?
        scope.all
      else
        scope.invited
      end
    end
  end
end
