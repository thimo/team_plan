# frozen_string_literal: true

class TrainingPolicy < ApplicationPolicy
  def show?
    create? || @user.team_member_for?(@record)
  end

  def new?
    create?
  end

  def create?
    return false if @record.team.archived?

    @user.admin? ||
      @user.club_staff_for?(@record) ||
      @user.team_staff_for?(@record)
  end

  def update?
    create?
  end

  def destroy?
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
