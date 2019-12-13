class TrainingPolicy < ApplicationPolicy
  def show?
    create? || @user.team_member_for?(@record)
  end

  def create?
    return false if @record.team.archived?

    @user.role?(Role::TRAINING_CREATE, @record) ||
      @user.team_staff_for?(@record)
  end

  def update?
    create?
  end

  def destroy?
    return false if @record.new_record?

    create?
  end

  def update_presences?
    return false if @record.team.archived?

    @user.team_staff_for?(@record)
  end

  def show_presences?
    update_presences?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
