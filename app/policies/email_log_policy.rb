# frozen_string_literal: true

class EmailLogPolicy < AdminPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
end
