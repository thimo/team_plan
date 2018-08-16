class Group < ApplicationRecord
  rolify

  has_many :group_users, dependent: :destroy
  has_many :users, through: :group_users

  validates :name, presence: true

  scope :asc, -> { order(name: :asc) }
end
