class TrainingPolicy < ApplicationPolicy
  def show?
    create? || @user.is_team_member_for?(@record)
  end

  def new?
    create?
  end

  def create?
    @user.admin? ||
    @user.club_staff? ||
    @user.is_team_staff_for?(@record)
  end

  def update?
    create?
  end

  def destroy?
    return false if @record.new_record?

    update?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
