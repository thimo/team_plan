module Admin
  class RolesController < Admin::BaseController
    before_action :create_resource, only: [:new, :create]
    before_action :set_resource, only: [:show, :edit, :update, :destroy]
    before_action :add_breadcrumbs

    def index
      @roles = policy_scope(Role).asc
      authorize @roles
    end

    def show; end

    def new; end

    def create
      if @role.save
        redirect_to admin_roles_path, notice: "Rol is toegevoegd."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @role.update(permitted_attributes(@role))
        redirect_to admin_roles_path, notice: "Rol is aangepast."
      else
        render "edit"
      end
    end

    def destroy
      redirect_to admin_roles_path, notice: "Rol is verwijderd."
      @role.destroy
    end

    private

      def create_resource
        @role = Role.new
        @role.assign_attributes(permitted_attributes(@role)) if action_name == "create"
        authorize @role
      end

      def set_resource
        @role = Role.find(params[:id])
        authorize @role
      end

      def add_breadcrumbs
        add_breadcrumb "Rollen", admin_roles_path
        return if @role.nil?

        if @role.new_record?
          add_breadcrumb "Nieuw"
        else
          add_breadcrumb @role.name, [:edit, :admin, @role]
        end
      end
  end
end
