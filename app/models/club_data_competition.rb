class ClubDataCompetition < ApplicationRecord
  include Activatable

  has_and_belongs_to_many :club_data_teams
  has_many :club_data_matches

  scope :asc, -> { order(:id) }

end
