class AgeGroup < ApplicationRecord
  include Statussable

  belongs_to :season
  has_many :teams, dependent: :destroy
  has_many :team_members, through: :teams
  has_many :members, through: :team_members
  has_many :favorites, as: :favorable, dependent: :destroy
  has_paper_trail

  validates_presence_of :name, :season, :gender

  scope :male, -> { where(gender: "m").or(AgeGroup.where(gender: nil)) }
  scope :female, -> { where(gender: "v") }
  scope :asc, -> {order(year_of_birth_to: :asc)}
  scope :active_or_archived, -> { where(status: [AgeGroup.statuses[:archived], AgeGroup.statuses[:active]]) }

  def is_not_member(member)
    TeamMember.where(member_id: member.id).joins(team: { age_group: :season }).where(seasons: { id: season.id }).empty?
  end

  def is_favorite?(user)
    favorites.where(user: user).size > 0
  end

  def favorite(user)
    favorites.where(user: user).first
  end

  def active_members
    # All active players
    members = Member.sportlink_active.sportlink_player.asc
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
    active_members.by_season(season).as_player
  end

  def status_children
    teams
  end

end
