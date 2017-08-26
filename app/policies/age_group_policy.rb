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
    return false if @record.draft?

    @user.admin? || @user.club_staff?
  end

  def show_evaluations?
    @user.admin? || @user.club_staff?
  end

  def show_todos?
    return false if @record.archived?

    @user.admin? || @user.club_staff?
  end

  def show_injureds?
    show_todos?
  end

  def show_available_members?
    show_todos?
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

  def bulk_email?
    download_team_members?
  end

  def permitted_attributes
    attributes = [:name, :year_of_birth_from, :year_of_birth_to, :gender, :players_per_team, :minutes_per_half]
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
