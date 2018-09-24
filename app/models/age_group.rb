# frozen_string_literal: true

class AgeGroup < ApplicationRecord
  include Statussable

  belongs_to :season
  has_many :teams, dependent: :destroy
  has_many :team_members, through: :teams
  has_many :members, through: :team_members
  has_many :favorites, as: :favorable, dependent: :destroy
  has_many :todos, as: :todoable, dependent: :destroy
  has_many :matches, through: :teams
  has_many :group_members, as: :memberable, dependent: :destroy
  has_many :groups, through: :group_members
  has_paper_trail

  validates :name, :season, presence: true

  scope :male, -> { where(gender: "m").or(AgeGroup.where(gender: [nil, "all", ""])) }
  scope :female, -> { where(gender: "v") }
  scope :asc, -> { order(year_of_birth_to: :asc) }
  scope :active_or_archived, -> { where(status: [AgeGroup.statuses[:archived], AgeGroup.statuses[:active]]) }

  PLAYER_COUNT = [4, 5, 6, 7, 8, 9, 11].freeze
  MINUTES_PER_HALF = [20, 25, 30, 35, 40, 45].freeze
  GENDER = [%w[Man m], %w[Vrouw v], %w[Alle all]].freeze

  def not_member?(member)
    TeamMember.where(member_id: member.id).joins(team: { age_group: :season }).where(seasons: { id: season.id }).empty?
  end

  def favorite?(user)
    favorites.where(user: user).size.positive?
  end

  def favorite(user)
    favorites.find_by(user: user)
  end

  def active_members
    # All active players
    members = Member.sportlink_active.sportlink_active_for_season(season).sportlink_player.asc
    # Filter on year of birth
    members = members.from_year(year_of_birth_from) if year_of_birth_from.present?
    members = members.to_year(year_of_birth_to) if year_of_birth_to.present?
    # Filter on gender
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

  def assigned_active_members
    active_members.by_season(season).player.active_in_a_team
  end

  def status_children
    teams
  end
end
