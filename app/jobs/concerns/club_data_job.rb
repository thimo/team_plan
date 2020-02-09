# frozen_string_literal: true

module ClubDataJob
  extend ActiveSupport::Concern

  included do
    private

      def skip_update?
        Season.active_season_for_today.nil? || Tenant.setting("clubdata_client_id").blank?
      end
  end
end
