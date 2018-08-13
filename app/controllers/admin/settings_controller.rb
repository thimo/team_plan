# frozen_string_literal: true

module Admin
  class SettingsController < Admin::BaseController
    before_action :set_setting, only: [:edit, :update]
    before_action :add_breadcrumbs

    def index
      @settings = Setting.get_all
      skip_policy_scope
    end

    def edit; end

    def update
      if @setting.value != params[:setting][:value]
        @setting.value = params[:setting][:value]
        @setting.save
        redirect_to admin_settings_path, notice: "Setting has updated."
      else
        redirect_to admin_settings_path
      end
    end

    private

      def set_setting
        @setting = Setting.find_by(var: params[:id]) || Setting.new(var: params[:id], value: Setting[params[:id]])
        authorize Setting
      end

      def add_breadcrumbs
        add_breadcrumb "Instellingen", admin_settings_path
        return if @setting.nil?

        add_breadcrumb @setting.var
      end
  end
end
