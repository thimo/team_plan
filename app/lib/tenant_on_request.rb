# frozen_string_literal: true

require "rack/request"

class TenantOnRequest
  def initialize(app, processor)
    @app = app
    @processor = processor
  end

  def call(env)
    request = Rack::Request.new(env)
    tenant = @processor.call(request)
    raise "Tenant not set for #{request.host}" if tenant.nil?

    ActsAsTenant.with_tenant(tenant) { @app.call(env) }
  end
end
