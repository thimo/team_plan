# frozen_string_literal: true

class TeamActionPolicy < ApplicationPolicy
  def new?
    create?
  end

  def create?
    @user.admin? || @user.club_staff_for?(@record)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
