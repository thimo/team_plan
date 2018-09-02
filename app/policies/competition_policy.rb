# frozen_string_literal: true

class CompetitionPolicy < ApplicationPolicy
  def index?
    @user.role?(:beheer_vereniging)
  end

  def create?
    index?
  end

  def show?
    true
  end

  def update?
    index?
  end

  def destroy?
    index? && @record.persisted?
  end

  class Scope < Scope
    def resolve
      scope.all if @user.role?(:beheer_vereniging)
    end
  end
end
