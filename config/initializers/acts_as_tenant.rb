# frozen_string_literal: true

require "tenant_on_request"

ActsAsTenant.configure do |config|
  config.require_tenant = defined?(Rails::Server) || defined?(Rails::Console)

  # Used to be inserted before Warden::Manager, but that means on 404/500/etc. errors
  # TenantOnRequest is not yet called
  Rails.application.config.middleware.insert_before(Rack::Runtime, TenantOnRequest,
                                                    proc { |request|
                                                      Tenant.from_request(request)
                                                    })
end
