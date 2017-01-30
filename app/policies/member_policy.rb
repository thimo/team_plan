class MemberPolicy < AdminPolicy
  def show?
    true
  end

  def import?
    create? && update?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
