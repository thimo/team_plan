# frozen_string_literal: true

class PlayBanPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_CONTRIBUTIE_SPEELVERBODEN)
  end

  def show?
    index?
  end

  def create?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index? && @record.persisted?
  end

  def permitted_attributes
    attributes = [:member_id, :started_on, :ended_on, :body]
    attributes << :play_ban_type if false # Use has acces to multiple roles
    attributes
  end

  class Scope < Scope
    def resolve
      return scope.contribution if @user.role?(Role::BEHEER_CONTRIBUTIE_SPEELVERBODEN)
      scope.none
    end
  end
end
