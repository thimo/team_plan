class ClubDataTeam < ApplicationRecord
  include Activatable

  has_one :team
  has_and_belongs_to_many :club_data_competitions

  scope :asc, -> { order(:id) }

  def link_to_team
    if team.nil?
      team = Team.for_active_season.find_by(name: teamnaam)
      team ||= Team.for_active_season.where("teams.name like (?)", "#{teamnaam}%").first
      stripped_teamname = teamnaam.gsub(Setting['club.name'], '').strip
      team ||= Team.for_active_season.where("teams.name like (?)", "#{stripped_teamname}%").first
      if team&.no_club_data_link?
        team.club_data_team = self
        team.save
      end
    end
  end
end
