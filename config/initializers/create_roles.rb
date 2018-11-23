# frozen_string_literal: true

Tenant.find_each do |tenant|
  ActsAsTenant.with_tenant(tenant) do
    Role.create_all
  end
end
