# frozen_string_literal: true

class CompetitionPolicy < AdminPolicy
  def show?
    true
  end

  def destroy?
    # TODO: Create different checks for local competitions (oefenwedstrijden) en KNVB competitions
    @user.admin? && @record.persisted?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
