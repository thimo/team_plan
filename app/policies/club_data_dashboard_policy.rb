# frozen_string_literal: true

class ClubDataDashboardPolicy < AdminPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
end
