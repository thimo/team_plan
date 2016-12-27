class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :member

  enum role: {role_player: 0, role_coach: 1, role_trainer: 2, role_coach_trainer: 3, role_team_parent: 4}

  validates_presence_of :team, :member, :joined_on, :role

end
