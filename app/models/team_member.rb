class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :member

  enum role: {role_player: 0, role_coach: 1, role_trainer: 2, role_team_parent: 3}

  validates_presence_of :team, :member, :role
  validates :role, :uniqueness => {:scope => [:team, :member]}

  scope :players, -> { includes(:member).where(role: TeamMember.roles[:role_player])}
  scope :staff, -> { includes(:member).where.not(role: TeamMember.roles[:role_player])}

  scope :asc, -> {joins(:member).order('members.last_name ASC, members.first_name ASC') }

  def age_group
    team.age_group
  end

  def season
    age_group.season
  end

  def draft?
    team.age_group.season.draft
  end

  def active?
    team.age_group.season.active?
  end

  def archived?
    team.age_group.season.archived?
  end
end
