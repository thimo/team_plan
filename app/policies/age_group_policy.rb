# frozen_string_literal: true

class AgeGroupPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    return false if @record.season.archived?

    @user.role?(Role::AGE_GROUP_CREATE)
  end

  def update?
    @user.role?(Role::AGE_GROUP_UPDATE, @record)
  end

  def destroy?
    return false if @record.archived? || @record.active?

    create?
  end

  def show_favorite?
    !@record.draft?
  end

  def show_evaluations?
    @user.admin? || @user.role?(Role::AGE_GROUP_SHOW_EVALUATIONS, @record)
  end

  def show_play_bans?
    return false if @record.archived?

    @user.admin? || @user.role?(Role::PLAY_BAN_SHOW, @record)
  end

  def show_todos?
    return false if @record.archived?

    @user.admin? || @user.role?(Role::AGE_GROUP_SHOW_TODOS, @record)
  end

  def show_injureds?
    show_todos?
  end

  def show_available_members?
    show_todos?
  end

  def show_status?
    return false if @record.status == @record.season.status

    @user.admin? || @user.role?(Role::STATUS_DRAFT) || @user.indirect_role?(Role::STATUS_DRAFT)
  end

  def show_member_count?
    return false if @record.season.archived?

    @user.admin? || @user.role?(Role::AGE_GROUP_SHOW_MEMBER_COUNT, @record)
  end

  def set_status?
    return false if @record.new_record? || @record.season.archived?

    @user.admin?
  end

  def team_actions?
    @user.admin? || @user.role?(Role::AGE_GROUP_TEAM_ACTIONS, @record)
  end

  def download_team_members?
    team_actions?
  end

  def bulk_email?
    team_actions?
  end

  def modify_members?
    @user.role?(Role::BEHEER_GROUPS) &&
      @record.persisted? && !@record.archived?
  end

  def permitted_attributes
    attributes = [:name, :year_of_birth_from, :year_of_birth_to, :gender, :players_per_team, :minutes_per_half]
    attributes << :status if set_status?
    attributes
  end

  class Scope < Scope
    def resolve
      if @user.admin? || @user.role?(Role::STATUS_DRAFT) || @user.indirect_role?(Role::STATUS_DRAFT)
        scope
      else
        scope.active_or_archived
      end
    end
  end
end
