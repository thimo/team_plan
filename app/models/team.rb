class Team < ApplicationRecord
  belongs_to :year_group
  has_many :team_members
end
