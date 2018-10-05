# frozen_string_literal: true

class TeamMemberPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    return false if @record&.team.archived?

    @user.admin? || @user.club_staff_for?(@record)
  end

  def update?
    return false if @record.archived?

    create? || (@user.team_staff_for?(@record) && @record.player?)
  end

  def set_role?
    @user.admin? || @user.club_staff_for?(@record)
  end

  def destroy?
    return false if @record.team.archived? # Never edit a team member for an archived team
    return true if @record.active? && @user.admin? # Admin can always remove team members in an active season

    (@record.draft? || @record.active?) && (@user.admin? || @user.club_staff_for?(@record))
  end

  def activate?
    # Only activate for active teams
    return false unless @record.team.active?
    return false if @record.active?

    @user.admin? || @user.club_staff_for?(@record)
  end

  def show_status?
    return false if @record.status == @record.team.status

    @user.admin? || @user.club_staff_for?(@record)
  end

  def set_status?
    return false if @record.new_record? || @record.team.archived?

    @user.admin?
  end

  def set_initial_status?
    return false if @record.persisted? || @record.team.nil? || @record.team.draft? || @record.team.archived?

    @user.admin? || @user.club_staff_for?(@record)
  end

  def permitted_attributes
    attributes = [:team_id, :member_id, :prefered_foot, field_position_ids: []]
    attributes << :role if set_role?
    attributes << :status if set_status?
    attributes << :initial_status if set_initial_status?
    attributes
  end

  class Scope < Scope
    def resolve
      if @user.admin? || @user.club_staff_for?(@record)
        scope
      else
        scope.active_or_archived
      end
    end
  end
end
