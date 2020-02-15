# frozen_string_literal: true

class RefereeImportJob < Que::Job
  def run(tenant_id:)
    ActsAsTenant.with_tenant(Tenant.find(tenant_id)) do
      referees = VoetbalassistRefereeScraper.new.run

      referees.each do |wedstrijdnummer, referee|
        match = Match.own.find_by(wedstrijdnummer: wedstrijdnummer)
        match.update(website_referee: referee) if match.present?
      end

      ClubDataLog.create level: :info,
                         source: :referee_import,
                         body: "#{referees.count { |_nr, ref| ref.present? }} scheidsrechters geïmporteerd"
    end
  end
end
