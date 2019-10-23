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
    return if ActsAsTenant.current_tenant.nil?

    ActsAsTenant.current_tenant.tenant_setting.send(clean_up(name))
  end

  def self.set_setting(name, value)
    return if ActsAsTenant.current_tenant.nil?

    ActsAsTenant.current_tenant.tenant_setting.update(clean_up(name) => value)
  end

  ##
  # Private class methods, should be called with tenant context
  #
  class << self
    private

      def clean_up(name)
        name.gsub(/[-\.]/, "_")
      end
  end
end
