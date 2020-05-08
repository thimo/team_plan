module Admin
  class TenantSettingsController < Admin::BaseController
    before_action :set_tenant_setting, only: [:edit, :update]
    before_action :add_breadcrumbs

    def edit
    end

    def update
      if @tenant_setting.update(permitted_attributes(@tenant_setting))
        redirect_to [:edit, :admin, @tenant_setting], notice: "Instellingen zijn aangepast."
      else
        render "edit"
      end
    end

    private

    def set_tenant_setting
      @tenant_setting = TenantSetting.find(params[:id])
      authorize @tenant_setting
    end

    def add_breadcrumbs
      add_breadcrumb "Instellingen", [:edit, :admin, @tenant_setting]
    end
  end
end
