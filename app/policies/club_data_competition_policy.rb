class ClubDataCompetitionPolicy < AdminPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
end
