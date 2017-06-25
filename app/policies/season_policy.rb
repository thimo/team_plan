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

    # Only by admin
    @user.admin?
  end

  def destroy?
    return false if @record.archived? || @record.active?

    # Only by admin
    @user.admin?
  end

  def set_status?
    return false if @record.new_record?

    @user.admin?
  end

  def download_team_members?
    @user.admin? || @user.club_staff?
  end

  def permitted_attributes
    attributes = [:name]
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
