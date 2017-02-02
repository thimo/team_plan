class Team < ApplicationRecord
  belongs_to :year_group
  has_many :team_members, dependent: :destroy
  has_many :members, through: :team_members
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :team_member_players, -> { player }, class_name: "TeamMember"
  has_many :team_member_coaches, -> { coach }, class_name: "TeamMember"
  has_many :team_member_trainers, -> { trainer }, class_name: "TeamMember"
  has_many :team_member_team_parents, -> { team_parent }, class_name: "TeamMember"

  has_many :players, through: :team_member_players, class_name: "Member", source: :member
  has_many :coaches, through: :team_member_coaches, class_name: "Member", source: :member
  has_many :trainers, through: :team_member_trainers, class_name: "Member", source: :member
  has_many :team_parents, through: :team_member_team_parents, class_name: "Member", source: :member

  validates_presence_of :name, :year_group

  scope :asc, -> { order(:created_at) }
end
