class Member < ApplicationRecord
  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members
  has_many :comments, as: :commentable
  belongs_to :user

  validates_presence_of :first_name, :last_name, :email, :phone

  def name
    "#{first_name} #{middle_name} #{last_name}".squish
  end
end
