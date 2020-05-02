# == Schema Information
#
# Table name: age_groups
#
#  id                 :integer          not null, primary key
#  ended_on           :date
#  gender             :string
#  minutes_per_half   :integer
#  name               :string
#  players_per_team   :integer
#  started_on         :date
#  status             :integer          default("draft")
#  training_only      :boolean          default(FALSE)
#  year_of_birth_from :integer
#  year_of_birth_to   :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  season_id          :integer
#  tenant_id          :bigint
#
# Indexes
#
#  index_age_groups_on_season_id  (season_id)
#  index_age_groups_on_tenant_id  (tenant_id)
#

# AgeGroups have teams in certain age ranges
class AgeGroup < ApplicationRecord
  include Statussable

  acts_as_tenant :tenant
  belongs_to :season
  has_many :teams, dependent: :destroy
  has_many :team_members, through: :teams
  # This association does not seem to be used
  # has_many :members, through: :team_members
  has_many :favorites, as: :favorable, dependent: :destroy
  has_many :todos, as: :todoable, dependent: :destroy
  has_many :matches, through: :teams
  has_many :group_members, as: :memberable, dependent: :destroy
  has_many :members, through: :group_members
  has_many :groups, through: :group_members
  has_paper_trail

  validates :name, :season, presence: true

  scope :male, -> { where(gender: "m").or(AgeGroup.where(gender: [nil, "all", ""])) }
  scope :female, -> { where(gender: "v") }
  scope :all_gender, -> { where(gender: [nil, "all", ""]) }
  scope :asc, -> { order(:training_only, year_of_birth_to: :asc) }
  scope :draft_or_active, -> { where(status: [AgeGroup.statuses[:draft], AgeGroup.statuses[:active]]) }
  scope :active_or_archived, -> { where(status: [AgeGroup.statuses[:archived], AgeGroup.statuses[:active]]) }
  scope :by_team, ->(team) { joins(:teams).where(teams: { id: team }).distinct }
  scope :for_group_members, ->(members) {
    joins(:group_members).where(group_members: { memberable_type: "AgeGroup", member: members })
  }
  scope :for_active_season, -> { joins(:season).where(seasons: { status: Season.statuses[:active] }) }

  PLAYER_COUNT = [4, 5, 6, 7, 8, 9, 11].freeze
  MINUTES_PER_HALF = [20, 25, 30, 35, 40, 45].freeze
  GENDER = [%w[Man m], %w[Vrouw v], %w[Alle all]].freeze

  before_update :before_update_actions

  def not_member?(member)
    TeamMember.where(member_id: member.id).joins(team: { age_group: :season }).where(seasons: { id: season.id }).empty?
  end

  def favorite?(user)
    favorites.where(user: user).size.positive?
  end

  def favorite(user)
    favorites.find_by(user: user)
  end

  def active_players
    members = Member.active.active_for_season(season).sportlink_player
    filter_for_birth_date_and_gender(members)
  end

  def assigned_active_players
    active_players.by_season(season).player.active_in_a_team
  end

  def active_non_players
    # To prevent a huge list of volunteers being shown
    return Member.none if year_of_birth_from.blank?

    members = Member.active.active_for_season(season).sportlink_non_player.asc
    filter_for_birth_date_and_gender(members)
  end

  def assigned_active_non_players
    return AgeGroup.none if year_of_birth_from.blank?

    active_non_players.by_season(season).active_in_a_team
  end

  def status_children
    (teams.to_a + group_members.to_a).compact
  end

  def inactive_players?
    Member.by_age_group_as_active(self).inactive.any? ||
      Member.by_age_group_as_active_player(self).sportlink_non_player.any? ||
      Member.by_age_group_as_active_player_in_active_team(self).status_overschrijving.any? ||
      Member.by_age_group_as_active_player_in_active_team(self).local_teams_warning_sportlink.any?
  end

  def always_show_group_members?
    true
  end

  private

    def filter_for_birth_date_and_gender(members)
      members = members.from_year(year_of_birth_from) if year_of_birth_from.present?
      members = members.to_year(year_of_birth_to) if year_of_birth_to.present?

      if gender.present?
        case gender.upcase
        when "M"
          members = members.male
        when "V"
          members = members.female
        end
      end

      members
    end

    def before_update_actions
      return unless training_only

      self.players_per_team = nil
      self.minutes_per_half = nil
    end
end
