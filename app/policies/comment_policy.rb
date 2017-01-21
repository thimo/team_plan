class CommentPolicy < ApplicationPolicy
  def create?
    true
  end

  def update?
    @user.role_admin? || @record.user = @user
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
