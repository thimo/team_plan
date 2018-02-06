class ClubDataTeam < ApplicationRecord
  include Activatable

  validates_presence_of :teamcode, :teamnaam
  validates_uniqueness_of :teamcode

  has_one :team
  has_and_belongs_to_many :club_data_competitions

  scope :asc, -> { order(:id) }

  def link_to_team
    if team.nil?
      stripped_teamname = teamnaam.gsub(Setting['club.name'], '').strip

      team = Team.for_active_season.active.find_by(name: [teamnaam, stripped_teamname])
      team ||= Team.for_active_season.active.where("teams.name like (?) OR teams.name like (?)", "#{teamnaam}%", "#{stripped_teamname}%").first

      if team&.no_club_data_link?
        team.club_data_team = self
        team.save
      end
    end
  end
end
