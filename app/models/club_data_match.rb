class ClubDataMatch < ApplicationRecord
  belongs_to :club_data_competition
  belongs_to :team, optional: true

  scope :asc, -> { order(:wedstrijddatum) }
end
