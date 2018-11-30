# frozen_string_literal: true

class Tenant < ApplicationRecord
  include RailsSettings::Extend
  include Statussable

  def self.from_request(request)
    host_parts = request.host.split(".")
    domain = host_parts.last(2).join(".")
    subdomains = host_parts[0..-3]

    tenant = Tenant.find_by(domain: domain.downcase)
    tenant ||= Tenant.find_by(subdomain: subdomains.last.downcase) if subdomains.any?
    tenant ||= Tenant.first
    tenant
  end
end
