class TeamPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    index?
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

  def show_comments?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record)
  end

  def show_evaluations?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record)
  end

  def show_favorite?
    return false if @record.draft?

    true
  end

  def show_status?
    return false if @record.status == @record.age_group.status

    @user.admin? || @user.club_staff?
  end

  def set_status?
    return false if @record.new_record? || @record.age_group.archived?

    @user.admin?
  end

  def download_team_members?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record)
  end

  def bulk_email?
    download_team_members?
  end

  def permitted_attributes
    attributes = [:name, :division, :remark]
    attributes << :status if set_status?
    return attributes
  end

  class Scope < Scope
    def resolve
      if @user.admin? || @user.club_staff?
        scope
      else
        scope.where(status: [Team.statuses[:archived], Team.statuses[:active]])
      end
    end
  end
end
