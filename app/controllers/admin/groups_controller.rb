module Admin
  class GroupsController < Admin::BaseController
    before_action :create_resource, only: [:new, :create]
    before_action :set_resource, only: [:show, :edit, :update, :destroy]
    before_action :add_breadcrumbs

    def index
      @groups = policy_scope(Group).active.asc
      authorize @groups
    end

    def show
    end

    def new
    end

    def create
      if @group.save
        redirect_to [:edit, :admin, @group], notice: "Groep is toegevoegd."
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @group.update(permitted_attributes(@group))
        redirect_to admin_groups_path, notice: "Groep is aangepast."
      else
        render "edit"
      end
    end

    def destroy
      @group.deactivate
      redirect_to admin_groups_path, notice: "Groep is verwijderd."
    end

    private

    def create_resource
      @group = Group.new
      @group.assign_attributes(permitted_attributes(@group)) if action_name == "create"
      authorize @group
    end

    def set_resource
      @group = Group.find(params[:id])
      authorize @group
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
