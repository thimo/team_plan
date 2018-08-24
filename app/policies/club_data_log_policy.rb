# frozen_string_literal: true

class ClubDataLogPolicy < AdminPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
end
