class CompetitionPolicy < AdminPolicy
  def show?
    true
  end
  
  class Scope < Scope
    def resolve
      scope
    end
  end
end
