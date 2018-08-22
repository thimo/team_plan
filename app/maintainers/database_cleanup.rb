# frozen_string_literal: true

module DatabaseCleanup
  def self.purge_papertrail_versions
    PaperTrail::Version.where("created_at < ?", 6.months.ago).delete_all
  end

  def self.purge_club_data_log
    ClubDataLog.where("created_at < ?", 1.month.ago).delete_all
  end

  def self.purge_email_log
    EmailLog.where("created_at < ?", 3.months.ago).delete_all
  end

  def self.all
    purge_papertrail_versions
    purge_club_data_log
    purge_email_log
    User.activate_for_active_members
    User.deactivate_for_inactive_members
  end
end
