# frozen_string_literal: true

module Admin
  class GroupMembersController < Admin::BaseController
    before_action :create_resource, only: [:new, :create]
    before_action :set_resource, only: [:edit, :update, :destroy]
    before_action :add_breadcrumbs

    def new; end

    def create
      if @group_member.save
        redirect_to admin_groups_path, notice: "Groupslid is toegevoegd."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @group_member.update(permitted_attributes(@group_member))
        redirect_to admin_groups_path, notice: "Groupslid is aangepast."
      else
        render "edit"
      end
    end

    def destroy
      @group_member.deactivate
      redirect_to admin_groups_path, notice: "Groupslid is verwijderd."
    end

    private

      def create_resource
        @group = Group.find(params[:group_id])

        @group_member = GroupMember.new
        @group_member.update(permitted_attributes(@group_member)) if action_name == "create"
        @group_member.group = @group

        authorize @group_member
      end

      def set_resource
        @group_member = GroupMember.find(params[:id])
        authorize @group_member
      end

      def add_breadcrumbs
        add_breadcrumb "Groepen", admin_groups_path
        return if @group_member.nil?

        add_breadcrumb @group_member.group.name

        if @group_member.new_record?
          add_breadcrumb "Nieuw"
        else
          add_breadcrumb @group_member.member.name, [:edit, :admin, @group_member]
        end
      end
  end
end
