# frozen_string_literal: true

class MemberPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_VERENIGING)
  end

  def create?
    index?
  end

  def show?
    true
  end

  def update?
    index?
  end

  def destroy?
    index? && @record.persisted?
  end

  def import?
    process_import?
  end

  def process_import?
    create? && update?
  end

  def show_favorite?
    false
  end

  def show_private_data?
    @user.admin? ||
      @user.team_member_for?(@record) ||
      @user.role?(Role::MEMBER_SHOW_PRIVATE_DATA, @record)
  end

  def show_full_born_on?
    @user.admin? ||
      @user.has_member?(@record) ||
      @user.role?(Role::MEMBER_SHOW_FULL_BORN_ON, @record)
  end

  def show_conduct?
    @user.admin? ||
      @user.club_staff_for?(@record)
  end

  def show_sportlink_status?
    @user.admin? ||
      @user.club_staff_for?(@record)
  end

  def show_todos?
    show_private_data?
  end

  def show_evaluations?
    @user.admin? ||
      @user.team_staff_for?(@record) ||
      @user.has_member?(@record) ||
      @user.role?(Role::MEMBER_SHOW_EVALUATIONS, @record)
  end

  def show_play_ban?
    @user.admin? ||
      @user.club_staff_for?(@record) ||
      @user.team_staff_for?(@record) ||
      @user.has_member?(@record)
  end

  def show_comments?
    show_evaluations? ||
      @user.has_member?(@record)
  end

  def show_injuries?
    show_evaluations?
  end

  def show_new_members?
    @user.admin? ||
      @user.role?(Role::MEMBER_SHOW_NEW) || @user.indirect_role?(Role::MEMBER_SHOW_NEW)
  end

  def create_login?
    @user.admin?
  end

  def show_login?
    create_login?
  end

  def resend_password?
    create_login?
  end

  class Scope < Scope
    def resolve
      # Scope is also used for showing new members on dashboard, or injureds
      scope
    end
  end
end
