class Team < ApplicationRecord
  include Statussable

  DIVISION_OPTIONS = %w(2e\ divisie 3e\ divisie 4e\ divisie Hoofdklasse 1e\ klasse 2e\ klasse 3e\ klasse 4e\ klasse 5e\ klasse 6e\ klasse)

  belongs_to :age_group, touch: true
  belongs_to :club_data_team, optional: true
  has_many :team_members, dependent: :destroy
  has_many :members, through: :team_members
  has_many :active_members, -> { where(team_members: { status: TeamMember.statuses[:active] }) },
    through: :team_members,
    source: :member
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy
  has_many :team_evaluations, dependent: :destroy
  has_many :todos, as: :todoable, dependent: :destroy
  has_many :training_schedules, dependent: :destroy
  has_many :trainings, dependent: :destroy
  has_many :competitions, through: :club_data_team
  has_many :presences
  has_and_belongs_to_many :matches
  has_paper_trail

  validates_presence_of :name, :age_group

  scope :asc, -> { order(:name) }
  scope :for_members, -> (members) { joins(:team_members).where(team_members: { member_id: members }) }
  scope :as_player, -> { joins(:team_members).where(team_members: { role: TeamMember.roles[:player] }) }
  scope :for_season, -> (season) { joins(:age_group).where(age_groups: { season_id: season }) }
  scope :for_active_season, -> { joins(age_group: :season).where(seasons: { status: Season.statuses[:active] }) }
  scope :active_or_archived, -> { where(status: [Team.statuses[:archived], Team.statuses[:active]]) }
  scope :by_teamcode, -> (teamcode) { joins(:club_data_team).where(club_data_teams: { teamcode: teamcode }) }

  def is_favorite?(user)
    favorites.where(user: user).size > 0
  end

  def favorite(user)
    favorites.where(user: user).first
  end

  def status_children
    team_members
  end

  def self.comment_types
    Comment.comment_types.except(:membership)
  end

  def schedules(from:, up_to:)
    schedules = trainings.in_period(from, up_to).includes(:training_schedule, training_schedule: :soccer_field).to_a
    schedules += matches.in_period(from, up_to).to_a
    schedules.flatten.sort_by(&:started_at)
  end

  def no_club_data_link?
    club_data_team.nil?
  end

end
