# frozen_string_literal: true

class FavoritePolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    true
  end
end
