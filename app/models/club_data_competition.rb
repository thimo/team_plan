class ClubDataCompetition < ApplicationRecord
  include Activatable

  validates_presence_of :poulecode

  has_and_belongs_to_many :club_data_teams
  has_many :club_data_matches

  scope :asc,     -> { order(:created_at) }
  scope :desc,    -> { order(created_at: :desc) }
  scope :regular, -> { where(competitiesoort: 'regulier') }
  scope :other,   -> { where.not(competitiesoort: 'regulier') }

end
