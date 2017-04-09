class AgeGroup < ApplicationRecord
  belongs_to :season
  has_many :teams, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy

  validates_presence_of :name, :season, :gender

  scope :male, -> { where(gender: "m").or(AgeGroup.where(gender: nil)) }
  scope :female, -> { where(gender: "v") }
  scope :asc, -> {order(year_of_birth_to: :asc)}

  def is_not_member(member)
    TeamMember.where(member_id: member.id).joins(team: { age_group: :season }).where(seasons: { id: season.id }).empty?
  end

  def draft?
    season.draft?
  end

  def active?
    season.active?
  end

  def archived?
    season.archived?
  end

  def is_favorite?(user)
    favorites.where(user: user).size > 0
  end

  def favorite(user)
    favorites.where(user: user).first
  end

  def active_members
    # All active players
    members = Member.active.player.asc
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
end
