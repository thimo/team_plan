class ClubDataCompetition < ApplicationRecord
  include Activatable

  belongs_to :club_data_team

  scope :asc, -> { order(:id) }

end
