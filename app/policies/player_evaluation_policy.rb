class PlayerEvaluationPolicy < ApplicationPolicy
  # Player Evaluation controller does not implement this action. Remove?
  # def index?
  #   @user.admin? ||
  #     @user.role?(Role::MEMBER_SHOW_EVALUATIONS, @record) ||
  #     @user.team_staff_for?(@record)
  # end

  # Player Evaluation controller does not implement this action. Remove?
  # def show?
  #   @user.admin? ||
  #     @user.role?(Role::MEMBER_SHOW_EVALUATIONS, @record) ||
  #     @user.team_staff_for?(@record)
  # end

  def create?
    return false unless @record.team_evaluation.active?

    @user.role?(Role::MEMBER_CREATE_EVALUATIONS, @record)
  end

  def update?
    return false if @record.team_evaluation.finished_at.blank?

    create?
  end

  def destroy?
    return false if @record.team_evaluation.finished_at.blank?

    @user.role?(Role::MEMBER_CREATE_EVALUATIONS, @record)
  end

  def show_remark?
    !record.team_evaluation.hide_remark_from_player ||
      @user.admin? ||
      @user.role?(Role::MEMBER_SHOW_EVALUATIONS, @record) ||
      @user.team_staff_for?(@record)
  end

  class Scope < Scope
    def resolve
      # Coordinators get a scope with all player evaluations. Display will be
      # limited via MemberPolicy.show_evaluations?
      if user.role?(Role::MEMBER_SHOW_EVALUATIONS) || user.indirect_role?(Role::MEMBER_SHOW_EVALUATIONS)
        scope.all.finished
      else
        scope.public_or_as_team_staff(user).finished
      end
    end
  end
end
