# frozen_string_literal: true

class VersionUpdate < ApplicationRecord
  validates :released_at, :name, :body, presence: true

  has_paper_trail

  enum for_role: { member: 0, admin: 1, club_staff: 2 }

  scope :desc, -> { order(released_at: :desc) }
end
