# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  def show?
    !@record.draft? || @user.role?(Role::STATUS_DRAFT, @record)
  end

  def create?
    return false if @record.age_group.archived?

    @user.role?(Role::TEAM_CREATE, @record)
  end

  def update?
    create?
  end

  def destroy?
    return false unless @record.draft?

    @user.role?(Role::TEAM_DESTROY, @record)
  end

  # Tabs

  def show_schedule?
    true
  end

  def show_calendar?
    true
  end

  def show_competitions?
    !record.age_group.training_only
  end

  def show_team?
    true
  end

  def show_dossier?
    show_comments? || show_notes? || show_evaluations?
  end

  def show_statistics?
    club_or_team_staff? || @user.role?(Role::TEAM_SHOW_STATISTICS, @record)
  end

  def modify_members?
    return false if @record.new_record? || @record.archived?

    @user.role?(Role::BEHEER_GROUPS, @record) || @user.role?(Role::GROUP_MEMB_CREATE, @record)
  end

  def add_members?
    modify_members?
  end

  # Sections

  def show_comments?
    club_or_team_staff? || @user.role?(Role::TEAM_SHOW_COMMENTS, @record)
  end

  def show_notes?
    club_or_team_staff? || @user.role?(Role::TEAM_SHOW_NOTES, @record)
  end

  def show_evaluations?
    club_or_team_staff? || @user.role?(Role::TEAM_SHOW_EVALUATIONS, @record)
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
      @user.role?(Role::TEAM_SHOW_TODOS, @record) ||
      @user.team_member_for?(@record)
  end

  def show_status?
    return false if @record.status == @record.age_group.status

    @user.role?(Role::STATUS_DRAFT, @record) || @user.indirect_role?(Role::STATUS_DRAFT)
  end

  def show_alert?
    return false if @record.archived?

    @user.role?(Role::TEAM_MEMBER_ALERT, @record)
  end

  def show_previous_team?
    return false if @record.archived?

    @user.role?(Role::MEMBER_PREVIOUS_TEAM, @record)
  end

  def set_status?
    return false if @record.new_record? || !@record.age_group.active?

    @user.role?(Role::TEAM_SET_STATUS, @record)
  end

  def show_play_bans?
    return false if @record.archived?

    club_or_team_staff? || @user.role?(Role::PLAY_BAN_SHOW, @record)
  end

  def create_match?
    return false if @record.archived?

    club_or_team_staff?
  end

  def download_team_members?
    club_or_team_staff? || @user.role?(Role::TEAM_MEMBER_DOWNLOAD, @record)
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
      if @user.role?(Role::STATUS_DRAFT) || @user.indirect_role?(Role::STATUS_DRAFT)
        scope
      else
        scope.active_or_archived
      end
    end
  end

  private

    def club_or_team_staff?
      @user.admin? ||
        @user.team_staff_for?(@record)
    end
end
