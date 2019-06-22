# frozen_string_literal: true

class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  include Pundit
  include ApplicationHelper
  protect_from_forgery with: :exception
  impersonates :user

  before_action :set_locale
  before_action :default_breadcrumb
  before_action :set_paper_trail_whodunnit

  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?
  after_action :track_ahoy_action

  # Globally rescue Authorization Errors in controller.
  # Returning 403 Forbidden if permission is denied
  rescue_from Pundit::NotAuthorizedError, with: :permission_denied
  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_auth_token

  private

    def invalid_auth_token
      flash_message(:danger, "Je hebt een verouderde versie van de pagina gebruikt, probeer het nog een keer.")
      redirect_to back_url
    end

    def permission_denied
      flash_message(:danger, "Je hebt niet genoeg rechten om deze pagina te bekijken.")
      redirect_to root_path
    end

    def set_locale
      I18n.locale = params[:locale] if params[:locale].present?
    end

    def default_breadcrumb
      return if devise_controller? || self.class == DashboardsController

      add_breadcrumb "Home", :root_path
    end

    def back_url
      request.referer || root_path
    end

    def track_ahoy_action
      ahoy.track(request.fullpath, ahoy_request_params) if current_tenant.present?
    end

    def ahoy_request_params
      {
        original_url: request.original_url,
        path: request.path,
        fullpath: request.fullpath,
        method: request.method,
        query_parameters: request.query_parameters,
        request_parameters: request.request_parameters
      }
        .merge(request.path_parameters)
        .delete_if { |k, v| v.empty? }
    end
end
