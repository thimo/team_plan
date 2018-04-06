class Competition < ApplicationRecord
  include Activatable

  validates :poulecode, :competitienaam, presence: true
  validates :poulecode, uniqueness: true

  has_and_belongs_to_many :club_data_teams
  has_many :matches

  scope :asc,     -> { order(:created_at) }
  scope :desc,    -> { order(created_at: :desc) }
  scope :regular, -> { where(competitiesoort: 'regulier') }
  scope :other,   -> { where.not(competitiesoort: 'regulier') }
  scope :knvb,    -> { where('poulecode > 0')}
  scope :custom,  -> { where('poulecode < 0')}

  def self.new_custom_poulecode
    # Custom competitions have a poulecode < 0
    [order(:poulecode).first.poulecode, 0].min - 1
  end

  def name
    competitienaam
  end

end
