# frozen_string_literal: true

module ClubdataImporter
  class ResultsJob < ApplicationJob
    queue_as :default

    def perform(tenant_id:)
      ActsAsTenant.current_tenant = Tenant.find(tenant_id)

      count = { total: 0, updated: 0 }

      # Regular import of all club matches
      url = "#{Tenant.setting('clubdata_urls_uitslagen')}&client_id=#{Tenant.setting('clubdata_client_id')}"
      json = JSON.parse(RestClient.get(url))
      json.each do |data|
        count[:total] += 1
        match = Match.find_by(wedstrijdcode: data["wedstrijdcode"])
        next if match.nil?

        match.set_uitslag(data["uitslag"])
        if match.changed?
          match.save!
          count[:updated] += 1
        end
      end

      ClubDataLog.create level: :info,
                         source: :club_results_import,
                         body: "#{count[:total]} imported (#{count[:updated]} updated)"
      # rescue StandardError => e
      #   log_error(:club_results_import, generic_error_body(url, e))
    end
  end
end
