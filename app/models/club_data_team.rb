# frozen_string_literal: true

class ClubDataTeam < ApplicationRecord
  include Activatable

  acts_as_tenant :tenant
  belongs_to :season
  has_many :teams, dependent: :nullify
  has_many :club_data_team_competitions, dependent: :nullify
  has_many :competitions, through: :club_data_team_competitions

  validates :teamcode, :teamnaam, presence: true
  validates :teamcode, uniqueness: { scope: [:tenant, :season] }

  scope :asc, -> { order(:id) }

  def link_to_team
    return if teams.for_active_season.present?

    stripped_teamname = teamnaam.gsub(Setting["club.name"], "").gsub(Setting["club.name_short"], "").strip

    team = Team.for_active_season.active.find_by(name: [teamnaam, stripped_teamname])
    team ||= Team.for_active_season.active.find_by("teams.name like (?) OR teams.name like (?)",
                                                   "#{teamnaam}%",
                                                   "#{stripped_teamname}%")

    if team&.no_club_data_link?
      team.club_data_team = self
      team.save
    end
  end
end
