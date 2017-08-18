class ClubDataCompetition < ApplicationRecord
  include Activatable

  belongs_to :club_data_team
  has_many :club_data_matches

  scope :asc, -> { order(:id) }

end
