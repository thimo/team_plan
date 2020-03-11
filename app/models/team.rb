# frozen_string_literal: true

# Represents a team with players and staff
class Team < ApplicationRecord
  include Statussable

  DIVISION_OPTIONS = %w[1e\ divisie 2e\ divisie 3e\ divisie 4e\ divisie Hoofdklasse 1e\ klasse 2e\ klasse
                        3e\ klasse 4e\ klasse 5e\ klasse 6e\ klasse].freeze

  acts_as_tenant :tenant
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
  has_many :presences, dependent: :destroy
  has_many :group_members, as: :memberable, dependent: :destroy
  has_and_belongs_to_many :matches
  has_paper_trail

  validates :name, :age_group, presence: true

  delegate :season, to: :age_group

  scope :asc, -> { order(:name) }
  scope :for_members, ->(members) { joins(:team_members).where(team_members: { member_id: members, ended_on: nil }) }
  scope :for_group_members, ->(members) {
    joins(:group_members).where(group_members: { memberable_type: "Team", member: members })
  }
  scope :as_player, -> { joins(:team_members).where(team_members: { role: TeamMember.roles[:player] }) }
  scope :as_not_player, -> { joins(:team_members).where.not(team_members: { role: TeamMember.roles[:player] }) }
  scope :for_season, ->(season) { joins(:age_group).where(age_groups: { season_id: season }) }
  scope :for_active_season, -> { joins(age_group: :season).where(seasons: { status: Season.statuses[:active] }) }
  scope :active_or_archived, -> { where(status: [Team.statuses[:archived], Team.statuses[:active]]) }
  scope :by_teamcode, ->(teamcode) { joins(:club_data_team).where(club_data_teams: { teamcode: teamcode }) }
  scope :by_status, ->(status) { where(status: status) }

  before_update :before_update_actions

  def name=(value)
    self[:name] = value.upcase
  end

  def favorite?(user)
    !favorites.where(user: user).empty?
  end

  def favorite(user)
    favorites.find_by(user: user)
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

  def name_with_club
    "#{Tenant.setting('club_name_short')} #{name}"
  end

  def inactive_players?
    Member.by_team_as_active(self).inactive.any? ||
      Member.by_team_as_active_player(self).sportlink_non_player.any? ||
      active? && (
        Member.by_team_as_active_player(self).status_overschrijving.any? ||
        Member.by_team_as_active_player(self).disallowed_club_sports.any?
      )
  end

  def check_and_set_division(club_data_division)
    update(division: club_data_division) if DIVISION_OPTIONS.include?(club_data_division)
  end

  def always_show_group_members?
    false
  end

  def trainers
    team_members.trainers.active.asc
  end

  def self.check_division
    Team.active.each do |team|
      if (competition = team.competitions.regular.last).present?
        team.check_and_set_division(competition.klasse)
      end
    end
  end

  private

    def before_update_actions
      return unless age_group.training_only

      self.division = nil
      self.players_per_team = nil
      self.minutes_per_half = nil
    end
end
