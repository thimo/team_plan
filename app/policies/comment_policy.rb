class CommentPolicy < ApplicationPolicy
  def index?
    @user.admin?
  end

  def show?
    false
  end

  def show_generic?
    true
  end

  def show_technique?
    @user.role?(Role::COMMENT_TECHNIQUE, @record)
  end

  def show_behaviour?
    @user.role?(Role::COMMENT_BEHAVIOUR, @record)
  end

  def show_classification?
    @user.role?(Role::COMMENT_CLASSIFICATION, @record)
  end

  def show_membership?
    @user.role?(Role::COMMENT_MEMBERSHIP, @record)
  end

  def create?
    return false if @record.commentable.archived?

    @user.admin? ||
      @user.role?(Role::COMMENT_CREATE, @record) ||
      @user.team_member_for?(@record)
  end

  def update?
    return false if @record.commentable.archived?

    @user.admin? || @record.user = @user
  end

  def destroy?
    return false if @record.new_record? || @record.commentable.archived?

    update?
  end

  class Scope < Scope
    def resolve
      scope # TODO: filter for 'private'
    end
  end
end
