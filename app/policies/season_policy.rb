# frozen_string_literal: true

class SeasonPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::SEASON_INDEX) || @user.indirect_role?(Role::SEASON_INDEX)
  end

  def show?
    @record.archived? || @record.active? ||
      @user.role?(Role::STATUS_DRAFT) || @user.indirect_role?(Role::STATUS_DRAFT)
  end

  def create?
    # Only by admin
    @user.admin?
  end

  def update?
    return false if @record.archived?

    @user.admin?
  end

  def destroy?
    return false if @record.archived? || @record.active?

    @user.admin?
  end

  def set_status?
    return false if @record.new_record?

    @user.role?(Role::SEAON_SET_STATUS, @record)
  end

  def team_actions?
    @user.role?(Role::SEASON_TEAM_ACTIONS, @record)
  end

  def download_team_members?
    team_actions?
  end

  def bulk_email?
    team_actions?
  end

  def bulk_publish?
    team_actions?
  end

  def inherit_age_groups?
    update?
  end

  def permitted_attributes
    attributes = [:name, :started_on, :ended_on]
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
end
