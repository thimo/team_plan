# frozen_string_literal: true

class TeamMember < ApplicationRecord
  include Statussable

  PREFERED_FOOT_OPTIONS = %w[rechtsbenig linksbenig tweebenig onbekend].freeze

  before_create :inherit_fields

  belongs_to :team, touch: true
  belongs_to :member, touch: true
  has_many :player_evaluations, dependent: :destroy
  has_and_belongs_to_many :field_positions
  has_and_belongs_to_many :training_schedules
  has_paper_trail

  enum role: { player: 0, head_coach: 5, coach: 1, trainer: 2, assistant_trainer: 7, keeper_trainer: 9, team_parent: 3,
               manager: 4, leader: 10, physio: 6, referee: 11, assistant_referee: 8 }
  enum initial_status: { initial_active: 1, initial_draft: 0 }

  validates :team_id, :member_id, :role, presence: true
  validates :role, uniqueness: { scope: [:team, :member] }

  delegate :email, to: :member
  delegate :name, to: :member
  delegate :age_group, to: :team
  delegate :season, to: :age_group

  scope :staff, -> { where.not(role: TeamMember.roles[:player]).includes(:member) }
  scope :trainers, -> {
    where(role: [TeamMember.roles[:trainer],
                 TeamMember.roles[:assistent_trainer],
                 TeamMember.roles[:keeper_trainer]])
  }
  scope :asc, -> { includes(:member).order("members.last_name ASC, members.first_name ASC").includes(:team) }
  scope :includes_parents, -> { includes(:team).includes(team: :age_group).includes(team: { age_group: :season }) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :active_for_team, ->(team) {
    where(status: team.status, ended_on: nil).or(where(status: TeamMember.statuses[:active]))
  }
  scope :active_or_archived, -> {
    where(status: [TeamMember.statuses[:archived], TeamMember.statuses[:active]], ended_on: nil)
  }
  scope :draft_or_active, -> {
    where(status: [TeamMember.statuses[:draft], TeamMember.statuses[:active]], ended_on: nil)
  }
  scope :not_ended, -> { where(ended_on: nil) }
  scope :ended, -> { where.not(ended_on: nil) }

  def self.players_by_year(team_members_scope)
    # used to include includes(:member).includes(:team).includes(:field_positions).
    team_members = team_members_scope.player.asc.group_by { |team_member| team_member.member.born_on.year }
    team_members.sort_by { |year, _team_members| year }.reverse
  end

  def self.staff_by_member(team_members_scope)
    team_members_scope.staff.asc.includes(:member).includes(:team).group_by(&:member)
  end

  def inactive_for?(record)
    # TeamMember never has archived status if draft or active or no end date is filled in
    return false if draft? || active? || ended_on.blank?

    case [record.class]
    when [TeamEvaluation]
      # For finished team evaluations, compare end date of TeamMember to the finish date of TeamEvaluation
      return record.finished_at > ended_on if record.finished?
      true
    when [Team]
      true
    end
  end

  def deactivate(user: nil)
    if active?
      # TODO: send notification to member administration
      self.status = TeamMember.statuses[:archived]
      self.ended_on = Time.zone.today
      save

      # Place team member in archive
      member.logs << Log.new(body: "Gearchiveerd vanuit #{team.name}.", user: user)
    else
      # Log first...
      member.logs << Log.new(body: "Verwijderd uit #{team.name}.", user: user)
      destroy
    end
  end

  def initial_status
    @initial_status || :initial_active
  end

  private

    def inherit_fields
      return if (team_member = member.active_team_member).blank?

      self.prefered_foot = team_member.prefered_foot if prefered_foot.nil?

      return if field_positions.present?
      team_member.field_positions.each do |field_position|
        field_positions << field_position
      end
    end
end
