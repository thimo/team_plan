class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_locale
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index
  before_action :default_breadcrumb #, unless: :devise_controller?
  before_action :set_paper_trail_whodunnit

  # Globally rescue Authorization Errors in controller.
  # Returning 403 Forbidden if permission is denied
  rescue_from Pundit::NotAuthorizedError, with: :permission_denied
  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_auth_token

  private

    def invalid_auth_token
      flash[:danger] = "Je hebt een verouderde versie van de pagina gebruikt, probeer het nog een keer."
      redirect_to :back
    end

    def permission_denied
      flash[:danger] = "Je hebt niet genoeg rechten om deze pagina te bekijken."
      redirect_to root_path
    end

    def set_locale
      I18n.locale = params[:locale] if params[:locale].present?
    end

    def default_breadcrumb
      unless devise_controller? || self.class == DashboardsController
        add_breadcrumb "Home", :root_path
        add_breadcrumb "Seizoenen", Season unless self.class.parent == Admin || self.class == StaticPagesController
      end
    end

    def back_url
      request.referer
    end
end
