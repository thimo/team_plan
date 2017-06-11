class NotePolicy < ApplicationPolicy
  def show?
    false
  end

  def create?
    true
  end

  def update?
    @user.admin? || @record.user = @user
  end

  def destroy?
    return false if @record.new_record?

    update?
  end

  class Scope < Scope
    def resolve
      if @user.admin? # || @user.club_staff?
        scope
      else
        new_scope = scope.own #.or(scope.for_staff).or(scope.for_member(@))
        if @user.club_staff?
          new_scope = new_scope.or(scope.for_staff)
          # elsif @user.is_team_staff_for()
        end
      end
    end
  end
end
