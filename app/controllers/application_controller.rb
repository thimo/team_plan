class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  include Pundit
  include ApplicationHelper
  protect_from_forgery with: :exception
  impersonates :user

  # before_action :set_locale
  before_action :default_breadcrumb
  before_action :set_paper_trail_whodunnit
  before_action :set_current

  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  # Globally rescue Authorization Errors in controller.
  # Returning 403 Forbidden if permission is denied
  rescue_from Pundit::NotAuthorizedError, with: :permission_denied
  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_auth_token

  private

    def invalid_auth_token
      flash_message(:danger, "Je (mogelijk) hebt een verouderde versie van de pagina gebruikt, probeer het nog een keer.")
      redirect_to back_url
    end

    def permission_denied
      flash_message(:danger, "Je hebt niet genoeg rechten om deze pagina te bekijken.")
      redirect_to root_path
    end

    # def set_locale
    #   I18n.locale = params[:locale] if params[:locale].present?
    # end

    def default_breadcrumb
      return if devise_controller? || self.class == DashboardsController

      add_breadcrumb "Home", :root_path
    end

    def back_url
      request.referer || root_path
    end

    # Current is an object that is available even in models
    def set_current
      Current.user = current_user
      Current.session = session

      Current.request_id = request.uuid
      Current.user_agent = request.user_agent
      Current.ip_address = request.remote_ip
      Current.referer    = request.referer
      Current.path       = request.fullpath
    end
end
