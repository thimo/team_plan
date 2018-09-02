# frozen_string_literal: true

module Admin
  class GroupsController < Admin::BaseController
    before_action :create_group, only: [:new, :create]
    before_action :set_group, only: [:show, :edit, :update, :destroy]
    before_action :add_breadcrumbs

    def index
      @groups = policy_scope(Group).asc
    end

    def show; end

    def new; end

    def create
      if @group.save
        redirect_to admin_groups_path, notice: "Groep is toegevoegd."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @group.update(group_params)
        redirect_to admin_groups_path, notice: "Groep is aangepast."
      else
        render "edit"
      end
    end

    def destroy
      redirect_to admin_groups_path, notice: "Groep is verwijderd."
      @group.destroy
    end

    private

      def create_group
        @group = if action_name == "new"
                   Group.new
                 else
                   Group.new(group_params)
                 end
        authorize @group
      end

      def set_group
        @group = Group.find(params[:id])
        authorize @group
      end

      def group_params
        params.require(:group).permit(:name, member_ids: [], role_ids: [])
      end

      def add_breadcrumbs
        add_breadcrumb "Groepen", admin_groups_path
        return if @group.nil?

        if @group.new_record?
          add_breadcrumb "Nieuw"
        else
          add_breadcrumb @group.name, [:edit, :admin, @group]
        end
      end
  end
end
