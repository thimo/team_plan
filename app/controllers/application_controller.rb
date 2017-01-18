class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_locale
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Seizoenen", Season

  # Globally rescue Authorization Errors in controller.
  # Returning 403 Forbidden if permission is denied
  rescue_from Pundit::NotAuthorizedError, with: :permission_denied

  private

    def permission_denied
      store_location
      flash[:danger] = "Je hebt niet genoeg rechten om deze pagina te bekijken."
      # this is giving a redirect loop error
      # redirect_to(request.referrer || root_path)
      redirect_to root_path
    end

    def set_locale
      I18n.locale = params[:locale] if params[:locale].present?
    end

end
