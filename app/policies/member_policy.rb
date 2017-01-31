class MemberPolicy < AdminPolicy
  def show?
    true
  end

  def import?
    process_import?
  end

  def process_import?
    create? && update?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
