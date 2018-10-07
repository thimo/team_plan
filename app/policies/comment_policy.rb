# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def show?
    false
  end

  def show_generic?
    true
  end

  def show_technique?
    @user.admin? || @user.role?(Role::COMMENT_TECHNIQUE)
  end

  def show_behaviour?
    @user.admin? || @user.role?(Role::COMMENT_BEHAVIOUR)
  end

  def show_classification?
    @user.admin? || @user.role?(Role::COMMENT_CLASSIFICATION)
  end

  def show_membership?
    @user.admin? || @user.role?(Role::COMMENT_MEMBERSHIP)
  end

  def create?
    return false if @record.commentable.archived?

    @user.admin? ||
      @user.role?(Role::COMMENT_CREATE) ||
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
