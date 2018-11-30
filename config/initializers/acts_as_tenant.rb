# frozen_string_literal: true

ActsAsTenant.configure do |config|
  config.require_tenant = defined?(Rails::Server) || defined?(Rails::Console)

  Rails.application.config.middleware.insert_before(Warden::Manager, TenantOnRequest,
                                                    proc { |request|
                                                      # Tenant.from_request(request)
                                                    })
end
