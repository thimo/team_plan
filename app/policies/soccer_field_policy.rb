# frozen_string_literal: true

class SoccerFieldPolicy < AdminPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
end
