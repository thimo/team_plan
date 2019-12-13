class TeamEvaluationConfigPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_TEAM_EVALUATION_CONFIGS)
  end

  def create?
    index?
  end

  def show?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index? && @record.persisted?
  end

  def permitted_attributes
    [:name, :config_json, :status]
  end

  class Scope < Scope
    def resolve
      if @user.role?(Role::BEHEER_TEAM_EVALUATION_CONFIGS)
        scope.all
      else
        scope.active
      end
    end
  end
end
