class Team < ApplicationRecord
  belongs_to :year_group
  has_many :team_members, dependent: :destroy
  has_many :members, through: :team_members
  has_many :comments, as: :commentable

  validates_presence_of :name, :year_group

  scope :asc, -> { order(:created_at) }
end
