class YearGroup < ApplicationRecord
  belongs_to :season
  has_many :teams, dependent: :destroy

  validates_presence_of :name, :season

  scope :asc, -> {order(year_of_birth_to: :asc)}

  def is_not_member(member)
    TeamMember.where(member_id: member.id).joins(team: { year_group: :season }).where(seasons: { id: season.id }).empty?
  end
end
