class ClubDataTeam < ApplicationRecord
  has_one :team
  has_many :club_data_competities

  scope :asc, -> { order(:id) }

  def link_to_team
    if team.nil?
      team = Team.for_active_season.find_by(name: teamnaam)
      if team&.no_club_data_link?
        team.club_data_team = self
        team.save
      end
    end
  end
end
