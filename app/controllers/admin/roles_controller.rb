# frozen_string_literal: true

module Admin
  class RolesController < Admin::BaseController
    before_action :create_role, only: [:new, :create]
    before_action :set_role, only: [:show, :edit, :update, :destroy]
    before_action :add_breadcrumbs

    def index
      # TODO: filter on roles without resource
      @roles = policy_scope(Role).asc
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
      if @role.update(role_params)
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

      def create_role
        @role = if action_name == "new"
                  Role.new
                else
                  Role.new(role_params)
                end
        authorize @role
      end

      def set_role
        @role = Role.find(params[:id])
        authorize @role
      end

      def role_params
        params.require(:role).permit(:name, :description)
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
