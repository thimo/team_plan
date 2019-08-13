# frozen_string_literal: true

module Admin
  class GroupsRolesController < Admin::BaseController
    before_action :add_breadcrumbs

    def index
      @groups = policy_scope(Group).sort_by { |group| -1 * group.roles.size }
      @roles = policy_scope(Role).asc

      authorize(Group)
      authorize(Role)
    end

    def create
      group = Group.find(params[:group_id])
      role = Role.find(params[:role_id])
      authorize(group)
      authorize(role)

      group.roles << role

      redirect_to admin_groups_roles_path
    end

    def destroy
      group = Group.find(params[:group_id])
      role = Role.find(params[:role_id])
      authorize(group)
      authorize(role)

      group.roles.delete(role)

      redirect_to admin_groups_roles_path
    end

    private

      def add_breadcrumbs
        add_breadcrumb "Rollenmatrix", admin_groups_roles_path
      end
  end
end
