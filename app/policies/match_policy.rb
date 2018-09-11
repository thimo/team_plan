# frozen_string_literal: true

class MatchPolicy < ApplicationPolicy
  def index?
    @user.role?(:beheer_knvb_club_data) || @user.role?(:beheer_oefenwedstrijden)
  end

  def show?
    true
  end

  # def new?
  #   create?
  # end

  def create?
    @user.role?(:beheer_oefenwedstrijden) ||
      @user.team_staff_for?(@record)
  end

  def update?
    # Don't allow edits for KNVB imported matches
    return false if @record.knvb?

    # Admin/club_staff can edit all matches, team staff only those created by themselves
    @user.role?(:beheer_oefenwedstrijden) ||
      (@record.team_staff? && @user.team_staff_for?(@record))
  end

  def destroy?
    return false if @record.new_record?

    update?
  end

  def update_presences?
    return false if @record.afgelast?

    @user.team_staff_for?(@record)
  end

  def show_presences?
    update_presences?
  end

  def set_team?
    @user.role?(:beheer_oefenwedstrijden)
  end

  def permitted_attributes
    attributes = [:wedstrijddatum, :wedstrijdtijd, :uitslag, :opponent, :is_home_match, :competition_id, :remark,
                  :accomodatie, :plaats, :adres, :postcode, :telefoonnummer, :route]
    attributes
  end

  class Scope < Scope
    def resolve
      return scope.for_competition(Competition.custom) if @user.role?(:beheer_oefenwedstrijden)
      return scope if @user.role?(:beheer_knvb_club_data)
      scope.none
    end
  end
end
