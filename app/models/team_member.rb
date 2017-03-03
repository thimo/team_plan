class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :member

  enum role: {player: 0, coach: 1, trainer: 2, team_parent: 3}

  validates_presence_of :team, :member, :role
  validates :role, :uniqueness => {scope: [:team, :member]}

  scope :staff, -> {where.not(role: TeamMember.roles[:player]).includes(:member)}
  scope :asc, -> {includes(:member).order('members.last_name ASC, members.first_name ASC').includes(:team)}
  scope :includes_parents, -> {includes(:team).includes(team: :age_group).includes(team: {age_group: :season})}

  def age_group
    team.age_group
  end

  def season
    age_group.season
  end

  def draft?
    team.age_group.season.draft?
  end

  def active?
    team.age_group.season.active?
  end

  def archived?
    team.age_group.season.archived?
  end
end
