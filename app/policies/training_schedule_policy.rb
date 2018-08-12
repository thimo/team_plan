# frozen_string_literal: true

class TrainingSchedulePolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    return false if @record.team.archived?

    @user.admin? ||
      @user.club_staff? ||
      @user.team_staff_for?(@record.team)
  end

  def update?
    create?
  end

  def destroy?
    return false if @record.new_record?

    create?
  end

  def activate?
    return false if @record.new_record?

    create?
  end

  def update_presences?
    create?
  end

  def show_presences?
    create?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
