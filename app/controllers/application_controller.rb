class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  before_action :set_locale
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

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
