# == Schema Information
#
# Table name: club_data_teams
#
#  id                 :bigint           not null, primary key
#  active             :boolean          default(TRUE)
#  geslacht           :string
#  kalespelsoort      :string
#  leeftijdscategorie :string
#  speeldag           :string
#  speeldagteam       :string
#  spelsoort          :string
#  teamcode           :integer          not null
#  teamnaam           :string
#  teamsoort          :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  season_id          :bigint
#  tenant_id          :bigint
#
# Indexes
#
#  index_club_data_teams_on_season_id               (season_id)
#  index_club_data_teams_on_season_id_and_teamcode  (tenant_id,season_id,teamcode) UNIQUE
#  index_club_data_teams_on_tenant_id               (tenant_id)
#
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

    teamname_without_club = teamnaam.gsub(Tenant.setting("club_name"), "")
                                    .gsub(Tenant.setting("club_name_short"), "")
                                    .strip

    team = Team.for_active_season.active.find_by(name: [teamnaam, teamname_without_club])

    # Find with stripped G or M at end of teamname
    if team.nil? && teamname_without_club =~ /JO[0-9]+-[0-9]+[GM]$/
      team = Team.for_active_season.active.find_by(name: teamname_without_club.gsub!(/[GM]$/, ""))
    end

    team.update!(club_data_team: self) if team&.no_club_data_link?
  end
end
