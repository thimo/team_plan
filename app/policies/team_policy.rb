# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  def show?
    @user.admin? || @user.club_staff? || !@record.draft?
  end

  def create?
    return false if @record.age_group.archived?

    @user.admin? || @user.club_staff?
  end

  def update?
    create?
  end

  def destroy?
    return false unless @record.draft?

    @user.admin? || @user.club_staff?
  end

  # Tabs

  def show_schedule?
    true
  end

  def show_calendar?
    true
  end

  def show_competitions?
    true
  end

  def show_team?
    true
  end

  def show_dossier?
    club_or_team_staff?
  end

  def show_statistics?
    club_or_team_staff?
  end

  # Sections

  def show_comments?
    show_dossier?
  end

  def show_notes?
    show_dossier?
  end

  def show_evaluations?
    club_or_team_staff?
  end

  def show_presence_chart?
    show_statistics?
  end

  def show_favorite?
    return false if @record.draft?

    true
  end

  def show_schedules?
    true
  end

  def show_todos?
    return false if @record.archived?

    @user.admin? ||
      @user.club_staff? ||
      @user.team_member_for?(@record)
  end

  def show_status?
    return false if @record.status == @record.age_group.status

    @user.admin? || @user.club_staff?
  end

  def show_previous_team?
    return false if @record.archived?

    @user.admin? || @user.club_staff?
  end

  def set_status?
    return false if @record.new_record? || @record.age_group.archived?

    @user.admin?
  end

  def create_match?
    return false if @record.archived?

    club_or_team_staff?
  end

  def download_team_members?
    club_or_team_staff?
  end

  def bulk_email?
    download_team_members?
  end

  def permitted_attributes
    attributes = [:name, :division, :remark, :players_per_team, :minutes_per_half]
    attributes << :status if set_status?
    attributes
  end

  class Scope < Scope
    def resolve
      if @user.admin? || @user.club_staff?
        scope
      else
        scope.active_or_archived
      end
    end
  end

  private

    def club_or_team_staff?
      @user.admin? ||
        @user.club_staff? ||
        @user.team_staff_for?(@record)
    end
end
