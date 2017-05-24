class ClubDataDashboardPolicy < AdminPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
end
