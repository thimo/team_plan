# frozen_string_literal: true

class VersionUpdatePolicy < AdminPolicy
  class Scope < Scope
    def resolve
      scope
      if user.admin?
        scope.all
      elsif user.club_staff?
        scope.member.or(scope.club_staff)
      else
        scope.member
      end
    end
  end
end
