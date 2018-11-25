# frozen_string_literal: true

Tenant.active.find_each do |tenant|
  ActsAsTenant.with_tenant(tenant) do
    Role.create_all
  end
end if defined?(Rails::Server)
