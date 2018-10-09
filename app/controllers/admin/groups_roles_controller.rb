# frozen_string_literal: true

module Admin
  class GroupsRolesController < Admin::BaseController
    def index
      @groups = policy_scope(Group).sort_by { |group| -1 * group.roles.size }
      @roles = policy_scope(Role).asc

      authorize(Group)
      authorize(Role)
    end
  end
end
