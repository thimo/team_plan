module DatabaseCleanup
  def self.purge_papertrail_versions
    PaperTrail::Version.where(['created_at < ?', 6.months.ago]).delete_all
  end
end
