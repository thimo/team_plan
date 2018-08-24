# frozen_string_literal: true

class GroupPolicy < AdminPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end
end
