# frozen_string_literal: true

class Tenant < ApplicationRecord
  include Statussable

  has_one :tenant_setting, dependent: :destroy

  def settings
    # Auto-create tenant_setting
    tenant_setting || create_tenant_setting
  end

  def self.from_request(request)
    host_parts = request.host.split(".")
    domain = host_parts.last(2).join(".")
    subdomains = host_parts[0..-3]

    tenant = Tenant.find_by(domain: domain.downcase)
    tenant ||= Tenant.find_by(subdomain: subdomains.last.downcase) if subdomains.any?
    tenant
  end

  def self.setting(name)
    name.gsub!(/[-\.]/, "_")
    ActsAsTenant.current_tenant.tenant_setting.send(name)
  end

  def self.set_setting(name, value)
    name.gsub!(/[-\.]/, "_")
    ActsAsTenant.current_tenant.tenant_setting.update(name => value)
  end
end
