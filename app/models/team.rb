class Team < ApplicationRecord
  include Statussable

  belongs_to :age_group
  has_many :team_members, dependent: :destroy
  has_many :members, through: :team_members
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy
  has_many :team_evaluations, dependent: :destroy

  validates_presence_of :name, :age_group

  scope :asc, -> { order(:name) }
  scope :for_members, -> (members) { joins(:team_members).where(team_members: { member_id: members }) }
  scope :for_season, -> (season) { joins(:age_group).where(age_groups: { season_id: season }) }

  def is_favorite?(user)
    favorites.where(user: user).size > 0
  end

  def favorite(user)
    favorites.where(user: user).first
  end
end
