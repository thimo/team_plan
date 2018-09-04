# frozen_string_literal: true

class SoccerFieldPolicy < ApplicationPolicy
  def index?
    @user.role?(:beheer_vereniging)
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

  class Scope < Scope
    def resolve
      return scope if @user.role?(:beheer_vereniging)
      scope.none
    end
  end
end
