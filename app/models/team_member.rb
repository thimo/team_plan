class TeamMember < ApplicationRecord
  include Statussable

  PREFERED_FOOT_OPTIONS = %w(rechtsbenig linksbenig tweebenig onbekend)

  before_create :inherit_fields

  belongs_to :team, touch: true
  belongs_to :member, required: true, touch: true
  has_many :player_evaluations, dependent: :destroy
  has_and_belongs_to_many :field_positions
  has_paper_trail

  enum role: {player: 0, head_coach: 5, coach: 1, trainer: 2, team_parent: 3, manager: 4, physio: 6}
  STAFF_ROLES = [1, 2, 3, 4, 5, 6]

  validates_presence_of :team_id, :member_id, :role
  validates :role, :uniqueness => {scope: [:team, :member]}

  delegate :email, to: :member

  scope :staff, -> { where.not(role: TeamMember.roles[:player]).includes(:member) }
  scope :asc, -> { includes(:member).order('members.last_name ASC, members.first_name ASC').includes(:team) }
  scope :includes_parents, -> { includes(:team).includes(team: :age_group).includes(team: {age_group: :season}) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :active_for_team, -> (team) { where(status: team.status, ended_on: nil) }

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
