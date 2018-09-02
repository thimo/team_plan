# frozen_string_literal: true

class VersionUpdatePolicy < ApplicationPolicy
  def index?
    @user.role?(:beheer_applicatie)
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
      if @user.role?(:beheer_applicatie)
        scope.all
      elsif user.club_staff?
        scope.member.or(scope.club_staff)
      else
        scope.member
      end
    end
  end
end
