class MatchPolicy < ApplicationPolicy
  def index?
    @user.role?(Role::BEHEER_KNVB_CLUB_DATA) || @user.role?(Role::BEHEER_OEFENWEDSTRIJDEN)
  end

  def show?
    true
  end

  # def new?
  #   create?
  # end

  def create?
    @user.role?(Role::BEHEER_OEFENWEDSTRIJDEN) ||
      @user.team_staff_for?(@record)
  end

  def update?
    # Don't allow edits for KNVB imported matches
    return false if @record.knvb?

    @user.role?(Role::BEHEER_OEFENWEDSTRIJDEN) ||
      (@record.team_staff? && @user.team_staff_for?(@record))
  end

  def destroy?
    return false if @record.new_record?

    update?
  end

  def set_team?
    @user.role?(Role::BEHEER_OEFENWEDSTRIJDEN)
  end

  def update_presences?
    return false if @record.afgelast?

    @user.team_staff_for?(@record)
  end

  def show_presences?
    update_presences?
  end

  def show_match?
    true
  end

  def show_address?
    true
  end

  def permitted_attributes
    attributes = [:wedstrijddatum, :wedstrijdtijd, :end_time, :uitslag, :opponent, :is_home_match, :competition_id,
                  :remark, :accomodatie, :plaats, :adres, :postcode, :telefoonnummer, :route, :thuisteam, :uitteam]
    attributes
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
