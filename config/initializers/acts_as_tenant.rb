# frozen_string_literal: true

ActsAsTenant.configure do |config|
  config.require_tenant = true

  Rails.application.config.middleware.insert_before(Warden::Manager, TenantOnRequest,
                                                    proc { |request|
                                                      host_parts = request.host.split(".")
                                                      domain = host_parts.last(2).join(".")
                                                      subdomains = host_parts[0..-3]

                                                      tenant = Tenant.find_by(domain: domain.downcase)
                                                      if subdomains.any?
                                                        tenant ||= Tenant.find_by(subdomain: subdomains.last.downcase)
                                                      end
                                                      tenant ||= Tenant.first if Rails.env.development?
                                                      tenant
                                                    })
end
