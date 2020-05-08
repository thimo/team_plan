# == Schema Information
#
# Table name: competitions
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE)
#  competitienaam  :string
#  competitiesoort :string
#  klasse          :string
#  klassepoule     :string
#  poule           :string
#  poulecode       :integer          not null
#  ranking         :json
#  remark          :text
#  user_modified   :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  tenant_id       :bigint
#
# Indexes
#
#  index_competitions_on_poulecode  (tenant_id,poulecode) UNIQUE
#  index_competitions_on_tenant_id  (tenant_id)
#
class Competition < ApplicationRecord
  include Activatable

  COMPETITIESOORT_REGULIER = "regulier"

  acts_as_tenant :tenant
  has_many :club_data_team_competitions, dependent: :destroy
  has_many :club_data_teams, through: :club_data_team_competitions
  has_many :teams, through: :club_data_teams
  has_many :matches, dependent: :destroy
  has_paper_trail

  validates :competitienaam, presence: true
  validates :poulecode, uniqueness: {scope: :tenant}

  scope :asc, -> { order(:created_at) }
  scope :desc, -> { order(created_at: :desc) }
  scope :regular, -> { where(competitiesoort: COMPETITIESOORT_REGULIER) }
  scope :other, -> { where.not(competitiesoort: COMPETITIESOORT_REGULIER) }
  scope :knvb, -> { where("poulecode > 0") }
  scope :custom, -> { where("poulecode < 0") }

  def self.new_custom_poulecode
    # Custom competitions have a poulecode < 0
    [order(:poulecode).first.poulecode, 0].min - 1
  end

  def name
    competitienaam
  end

  def regular?
    competitiesoort == COMPETITIESOORT_REGULIER
  end

  def knvb?
    poulecode.positive?
  end

  def deactivate
    super
    matches.from_now.destroy_all
  end
end
