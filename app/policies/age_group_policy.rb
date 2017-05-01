class AgeGroupPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    return false if @record.season.archived?

    @user.admin? || @user.club_staff?
  end

  def update?
    create?
  end

  def destroy?
    return false if @record.archived? || @record.active?

    create?
  end

  def show_favorite?
    @user.admin? || @user.club_staff?
  end

  def show_evaluations?
    @user.admin? || @user.club_staff?
  end

  def show_status?
    return false if @record.status == @record.season.status

    @user.admin? || @user.club_staff?
  end

  def set_status?
    return false if @record.new_record? || @record.season.archived?

    @user.admin?
  end

  def download_team_members?
    @user.admin? || @user.club_staff?
  end

  def permitted_attributes
    attributes = [:name, :year_of_birth_from, :year_of_birth_to, :gender]
    attributes << :status if set_status?
    return attributes
  end

  class Scope < Scope
    def resolve
      if @user.admin? || @user.club_staff?
        scope
      else
        scope.where(status: [AgeGroup.statuses[:archived], AgeGroup.statuses[:active]])
      end
    end
  end
end
