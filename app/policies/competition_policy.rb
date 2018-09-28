# frozen_string_literal: true

class CompetitionPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_VERENIGING)
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
    # TODO: Create different checks for local competitions (oefenwedstrijden) en KNVB competitions
    index? && @record.persisted?
  end

  class Scope < Scope
    def resolve
      return scope.all if @user.role?(Role::BEHEER_VERENIGING)
      scope.none
    end
  end
end
