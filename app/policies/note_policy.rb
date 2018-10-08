# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  def show?
    return true if @record.self? && @record.user == @user
    return true if @record.staff? &&
                   (@user.admin? || @user.role?(Role::NOTE_SHOW, @record) || @user.team_staff_for?(@record))
    return true if @record.member? && @record.member == @user

    false
  end

  def new?
    create?
  end

  def create?
    @user.admin? ||
      @user.role?(Role::NOTE_CREATE, @record) ||
      @user.team_member_for?(@record)
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
      scope
    end
  end
end
