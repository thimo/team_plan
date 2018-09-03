# frozen_string_literal: true

class MatchPolicy < ApplicationPolicy
  def index?
    @user.role?(:beheer_knvb_club_data) || @user.role?(:beheer_oefenwedstrijden)
  end

  def show?
    true
  end

  def new?
    create?
  end

  def create?
    @user.admin? ||
      @user.club_staff? ||
      @user.team_staff_for?(@record)
  end

  def update?
    # Don't allow edits for KNVB imported matches
    return false if @record.knvb?

    # Admin/club_staff can edit all matches, team staff only those created by themselves
    @user.admin? ||
      @user.club_staff? ||
      (@record.team_staff? && @user.team_staff_for?(@record))
  end

  def destroy?
    return false if @record.new_record?

    update?
  end

  def update_presences?
    return false if @record.afgelast?

    create?
  end

  def show_presences?
    update_presences?
  end

  class Scope < Scope
    def resolve
      return scope.for_competition(Competition.custom) if @user.role?(:beheer_oefenwedstrijden)
      return scope if @user.role?(:beheer_knvb_club_data)
    end
  end
end
