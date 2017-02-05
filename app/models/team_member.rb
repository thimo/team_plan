class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :member

  enum role: {role_player: 0, role_coach: 1, role_trainer: 2, role_team_parent: 3}

  validates_presence_of :team, :member, :role
  validates :role, :uniqueness => {:scope => [:team, :member]}

  scope :player, -> { where(role: TeamMember.roles[:role_player])}
  scope :coach, -> { where(role: TeamMember.roles[:role_coach])}
  scope :trainer, -> { where(role: TeamMember.roles[:role_trainer])}
  scope :team_parent, -> { where(role: TeamMember.roles[:role_team_parent])}

  def year_group
    team.year_group
  end

  def season
    year_group.season
  end
end
