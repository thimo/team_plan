# frozen_string_literal: true

class ClubDataTeamPolicy < ApplicationPolicy
  def index?
    @user.role?(:beheer_knvb_club_data)
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
      scope.all if @user.role?(:beheer_knvb_club_data)
    end
  end
end
