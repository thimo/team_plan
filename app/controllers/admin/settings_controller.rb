# frozen_string_literal: true

module Admin
  class SettingsController < Admin::BaseController
    before_action :set_setting, only: [:edit, :update]
    before_action :add_breadcrumbs

    def index
      @settings = current_tenant.settings.get_all
      skip_policy_scope
      authorize Setting
    end

    def edit; end

    def update
      if @setting.value != params[:setting][:value]
        @setting.value = params[:setting][:value]
        @setting.save
        redirect_to admin_settings_path, notice: "Instelling is bewaard."
      else
        redirect_to admin_settings_path
      end
    end

    private

      def set_setting
        @setting = Setting.for_current_tenant(var: params[:id])
        authorize Setting
      end

      def add_breadcrumbs
        add_breadcrumb "Instellingen", admin_settings_path
        return if @setting.nil?

        add_breadcrumb @setting.var
      end
  end
end
