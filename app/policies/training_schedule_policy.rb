# frozen_string_literal: true

class TrainingSchedulePolicy < ApplicationPolicy
  def show?
    create? || @user.team_member_for?(@record.team)
  end

  def create?
    return false if @record.team.archived?

    @user.role?(Role::TRAINING_SCHEDULE_CREATE, @record.team) ||
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
    return false if @record.team.archived?

    @user.team_staff_for?(@record.team)
  end

  def show_presences?
    update_presences?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
