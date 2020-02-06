# frozen_string_literal: true

class ClubData::CancelationsJob < ApplicationJob
  queue_as :default

  def perform(tenant_id:)
    ActsAsTenant.current_tenant = Tenant.find(tenant_id)

    count = { total: 0, created: 0, deleted: 0 }

    # Regular import of all club matches
    url = "#{Tenant.setting('clubdata_urls_afgelastingen')}&client_id=#{Tenant.setting('clubdata_client_id')}"
    json = JSON.parse(RestClient.get(url))
    cancelled_matches = []
    json.each do |data|
      next if (match = Match.find_by(wedstrijdcode: data["wedstrijdcode"])).blank?

      match.attributes = { afgelast: true, afgelast_status: data["status"] }
      if match.changed?
        count[:created] += 1
        match.save!
      end

      cancelled_matches << data["wedstrijdcode"]
    end

    Season.active_season_for_today.matches.afgelast.each do |match|
      next if cancelled_matches.include? match.wedstrijdcode

      match.update!(
        afgelast: false,
        afgelast_status: ""
      )
      count[:deleted] += 1
    end

    ClubDataLog.create level: :info,
                       source: :afgelastingen_import,
                       body: "#{count[:total]} imported (#{count[:created]} created, \
                                                         #{count[:deleted]} deleted)"
    # rescue StandardError => e
    #   log_error(:teams_and_competitions_import, generic_error_body(url, e))
  end
end
