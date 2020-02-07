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

    if tenant
      ActsAsTenant.with_tenant(tenant) { @app.call(env) }
    elsif request.host == "localhost"
      puts '#' * 40
      puts 'request.host == "localhost"'
      puts request.host
      @app.call(env)
    else
      puts '#' * 40
      puts 'else'
      puts request.host
      [302, { "Location" => "https://www.defrog.nl/", "Content-Type" => "text/html" }, ["Found"]]
    end
  end
end
