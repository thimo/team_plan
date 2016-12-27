class Team < ApplicationRecord
  belongs_to :year_group
  has_many :team_members

  validates_presence_of :name, :year_group
end
