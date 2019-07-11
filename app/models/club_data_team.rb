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

    teamname_without_club = teamnaam.gsub(Tenant.setting("club.name"), "")
                                    .gsub(Tenant.setting("club.name_short"), "")
                                    .strip

    team = Team.for_active_season.active.find_by(name: [teamnaam, teamname_without_club])
    # team ||= Team.for_active_season.active.find_by("teams.name like (?) OR teams.name like (?)",
    #                                                "#{teamnaam}%",
    #                                                "#{teamname_without_club}%")

    # Find with stripped G or M at end of teamname
    if team.nil? && teamname_without_club =~ /JO[0-9]+-[0-9]+[GM]$/
      team = Team.for_active_season.active.find_by(name: teamname_without_club.gsub!(/[GM]$/, ""))
    end

    if team&.no_club_data_link?
      team.club_data_team = self
      team.save
    end
  end
end
