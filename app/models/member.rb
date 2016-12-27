class Member < ApplicationRecord
  has_many :team_members
  has_many :teams, through: :team_members

  validates_presence_of :first_name, :last_name, :email, :phone
end
