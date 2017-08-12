class SeasonPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
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

    @user.admin?
  end

  def download_team_members?
    @user.admin? || @user.club_staff?
  end

  def bulk_email?
    download_team_members?
  end

  def inherit_age_groups?
    update?
  end

  def permitted_attributes
    attributes = [:name, :started_on, :ended_on]
    attributes << :status if set_status?
    return attributes
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
end
