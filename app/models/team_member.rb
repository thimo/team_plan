class TeamMember < ApplicationRecord
  include Statussable

  PREFERED_FOOT_OPTIONS = %w(rechtsbenig linksbenig tweebenig onbekend)

  before_create :inherit_fields

  belongs_to :team, touch: true
  belongs_to :member, required: true, touch: true
  has_many :player_evaluations, dependent: :destroy
  has_and_belongs_to_many :field_positions
  has_and_belongs_to_many :training_schedules
  has_paper_trail

  enum role: {player: 0, head_coach: 5, coach: 1, trainer: 2, assistant_trainer: 7, keeper_trainer: 9, team_parent: 3, manager: 4, physio: 6, assistant_referee: 8}

  validates_presence_of :team_id, :member_id, :role
  validates :role, :uniqueness => {scope: [:team, :member]}

  delegate :email, to: :member
  delegate :name, to: :member

  scope :staff, -> { where.not(role: TeamMember.roles[:player]).includes(:member) }
  scope :trainers, -> { where(role: [TeamMember.roles[:trainer], TeamMember.roles[:assistent_trainer], TeamMember.roles[:keeper_trainer]]) }
  scope :asc, -> { includes(:member).order('members.last_name ASC, members.first_name ASC').includes(:team) }
  scope :includes_parents, -> { includes(:team).includes(team: :age_group).includes(team: {age_group: :season}) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :active_for_team, -> (team) { where(status: team.status, ended_on: nil).or(where(status: TeamMember.statuses[:active])) }
  scope :active_or_archived, -> { where(status: [TeamMember.statuses[:archived], TeamMember.statuses[:active]], ended_on: nil) }
  scope :draft_or_active, -> { where(status: [TeamMember.statuses[:draft], TeamMember.statuses[:active]], ended_on: nil) }
  scope :not_ended, -> { where(ended_on: nil) }
  scope :ended, -> { where.not(ended_on: nil) }

  def age_group
    team.age_group
  end

  def season
    age_group.season
  end

  def self.players_by_year(team_members_scope)
    # used to include includes(:member).includes(:team).includes(:field_positions).
    team_members_scope.player.asc.group_by{ |team_member| team_member.member.born_on.year }.sort_by{|year, team_members| year}.reverse
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
      if record.finished?
        return record.finished_at > ended_on
      else
        return true
      end
    when [Team]
      true
    end
  end

  def deactivate(user: nil)
    if active?
      # TODO send notification to member administration
      self.status = TeamMember.statuses[:archived]
      self.ended_on = Date.today
      save

      # Place team member in archive
      self.member.logs << Log.new(body: "Gearchiveerd vanuit #{team.name}.", user: user)
    else
      # Log first...
      self.member.logs << Log.new(body: "Verwijderd uit #{team.name}.", user: user)
      self.destroy
    end
  end

  private

    def inherit_fields
      if (team_member = member.active_team_member).present?
        self.prefered_foot = team_member.prefered_foot if self.prefered_foot.nil?
        team_member.field_positions.each do |field_position|
          self.field_positions << field_position
        end if self.field_positions.empty?
      end
    end
end
