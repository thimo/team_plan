# frozen_string_literal: true

class PresencePolicy < ApplicationPolicy
  def create?
    return false if @record.presentable.inactive?

    @user.admin? ||
      @user.team_staff_for?(@record)
  end

  def update?
    create?
  end

  def permitted_attributes
    attributes = [:is_present, :on_time, :signed_off, :remark]
    attributes << :member_id if @record.new_record?
    attributes
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
