class Admin::SettingsController < Admin::BaseController
  before_action :get_setting, only: [:edit, :update]

  def index
    @settings = Setting.get_all
    skip_policy_scope
  end

  def edit
  end

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

    def get_setting
      @setting = Setting.find_by(var: params[:id]) || Setting.new(var: params[:id], value: Setting[params[:id]])
      authorize Setting
    end
end
