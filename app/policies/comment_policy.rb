class CommentPolicy < ApplicationPolicy
  def show?
  end

  def create?
    true
  end

  def update?
    @user.admin? || @record.user = @user
  end

  def destroy?
    @user.admin? || @record.user = @user
  end

  class Scope < Scope
    def resolve
      scope # TODO filter for 'private'
    end
  end
end
