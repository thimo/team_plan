class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :member

  enum role: {role_player: 0, role_coach: 1, role_trainer: 2, role_team_parent: 3}

  validates_presence_of :team, :member, :role
  validates :role, :uniqueness => {:scope => [:team, :member]}

  scope :players, -> { where(role: TeamMember.roles[:role_player])}
  scope :staff, -> { where.not(role: TeamMember.roles[:role_player])}
  scope :coaches, -> { where(role: TeamMember.roles[:role_coach])}
  scope :trainers, -> { where(role: TeamMember.roles[:role_trainer])}
  scope :team_parents, -> { where(role: TeamMember.roles[:role_team_parent])}

  scope :asc, -> {joins(:member).order('members.last_name ASC, members.first_name ASC') }

  def age_group
    team.age_group
  end

  def season
    age_group.season
  end
end
