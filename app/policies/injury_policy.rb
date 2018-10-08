# frozen_string_literal: true

class InjuryPolicy < ApplicationPolicy
  def show?
    # Visible for club staff, author, member's team staff, member
    create? || @record.user = @user || @user.has_member?(@record.member)
  end

  def new?
    create?
  end

  def create?
    club_or_team_staff?
  end

  def update?
    create?
  end

  def destroy?
    return false if @record.new_record?

    update?
  end

  # Sections

  def show_comments?
    club_or_team_staff?
  end

  class Scope < Scope
    def resolve
      # TODO: limit scope if this is used
      scope
    end
  end

  private

    def club_or_team_staff?
      @user.admin? ||
        @user.role(Role::INJURY_CREATE, @record.member) ||
        @user.team_staff_for?(@record.member)
    end
end
