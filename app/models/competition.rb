# frozen_string_literal: true

class Competition < ApplicationRecord
  include Activatable

  acts_as_tenant :tenant
  has_many :club_data_team_competitions, dependent: :destroy
  has_many :club_data_teams, through: :club_data_team_competitions
  has_many :teams, through: :club_data_teams
  has_many :matches, dependent: :destroy
  has_paper_trail

  validates :competitienaam, presence: true
  validates :poulecode, uniqueness: { scope: :tenant }

  scope :asc,     -> { order(:created_at) }
  scope :desc,    -> { order(created_at: :desc) }
  scope :regular, -> { where(competitiesoort: "regulier") }
  scope :other,   -> { where.not(competitiesoort: "regulier") }
  scope :knvb,    -> { where("poulecode > 0") }
  scope :custom,  -> { where("poulecode < 0") }

  def self.new_custom_poulecode
    # Custom competitions have a poulecode < 0
    [order(:poulecode).first.poulecode, 0].min - 1
  end

  def name
    competitienaam
  end
end
