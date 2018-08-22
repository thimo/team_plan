# frozen_string_literal: true

class TodoPolicy < ApplicationPolicy
  def create?
    true
  end

  def update?
    @record.user = @user
  end

  def destroy?
    return false if @record.new_record?

    update?
  end

  def toggle?
    update?
  end

  class Scope < Scope
    def resolve
      scope.where(user: @user)
    end
  end
end
