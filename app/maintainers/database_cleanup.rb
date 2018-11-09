# frozen_string_literal: true

module DatabaseCleanup
  def self.all
    PaperTrail::Version.where("created_at < ?", 6.months.ago).delete_all
    ClubDataLog.where("created_at < ?", 1.month.ago).delete_all
    EmailLog.where("created_at < ?", 3.months.ago).delete_all
    User.activate_for_active_members
    User.deactivate_for_inactive_members
  end
end
