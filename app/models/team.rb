class Team < ApplicationRecord
  belongs_to :age_group
  has_many :team_members, dependent: :destroy
  has_many :members, through: :team_members
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favorable, dependent: :destroy
  has_many :team_evaluations, dependent: :destroy

  validates_presence_of :name, :age_group

  scope :asc, -> { order(:created_at) }

  def draft?
    age_group.season.draft?
  end

  def active?
    age_group.season.active?
  end

  def archived?
    age_group.season.archived?
  end

  def is_favorite?(user)
    favorites.where(user: user).size > 0
  end

  def favorite(user)
    favorites.where(user: user).first
  end
end
