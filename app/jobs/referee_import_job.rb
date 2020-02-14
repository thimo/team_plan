# frozen_string_literal: true

class RefereeImportJob < ApplicationJob
  queue_as :default

  def perform(tenant_id:)
    ActsAsTenant.current_tenant = Tenant.find(tenant_id)

    referees = VoetbalassistRefereeScraper.new.run

    referees.each do |wedstrijdnummer, referee|
      match = Match.own.find_by(wedstrijdnummer: wedstrijdnummer)
      match.update(website_referee: referee) if match.present?
    end
  end
end
