class ClubDataTeam < ApplicationRecord
  has_one :team
  has_many :club_data_competities

  scope :asc, -> { order(:id) }
end
