class Member < ApplicationRecord
  has_many :team_members, dependent: :destroy
  has_many :teams, through: :team_members

  validates_presence_of :first_name, :last_name, :email, :phone

  def name
    "#{first_name} #{middle_name + " " unless middle_name.blank?}#{last_name}"
  end
end
