# frozen_string_literal: true

class SettingPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_APPLICATIE)
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
      return scope.all if @user.role?(Role::BEHEER_APPLICATIE)
      scope.none
    end
  end
end
