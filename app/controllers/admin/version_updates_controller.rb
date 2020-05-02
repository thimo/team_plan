module Admin
  class VersionUpdatesController < Admin::BaseController
    before_action :create_resource, only: [:new, :create]
    before_action :set_resource, only: [:edit, :update, :destroy]
    before_action :add_breadcrumbs

    def index
      @version_updates = policy_scope(VersionUpdate).desc.page(params[:page]).per(10)
      authorize @version_updates
    end

    def new; end

    def create
      if @version_update.save
        redirect_to admin_version_updates_path, notice: "Versie is toegevoegd."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @version_update.update(version_update_params)
        redirect_to admin_version_updates_path, notice: "Versie is aangepast."
      else
        render "edit"
      end
    end

    def destroy
      redirect_to admin_version_updates_path, notice: "Versie is verwijderd."
      @version_update.destroy
    end

    private

      def create_resource
        @version_update = if action_name == "new"
                            VersionUpdate.new(released_at: Time.zone.today)
                          else
                            VersionUpdate.new(version_update_params)
                          end
        authorize @version_update
      end

      def set_resource
        @version_update = VersionUpdate.find(params[:id])
        authorize @version_update
      end

      def version_update_params
        params.require(:version_update).permit(:released_at, :name, :body, :for_role)
      end

      def add_breadcrumbs
        add_breadcrumb "Versie updates", admin_version_updates_path
        return if @version_update.nil?

        if @version_update.new_record?
          add_breadcrumb "Nieuw"
        else
          add_breadcrumb @version_update.released_at, [:edit, :admin, @version_update]
        end
      end
  end
end
