class VersionUpdate < ApplicationRecord
  validates_presence_of :released_at, :name, :body

  has_paper_trail
  
  enum for_role: {member: 0, admin: 1, club_staff: 2}

  scope :desc, -> { order(released_at: :desc)}
end
