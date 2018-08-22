class Group < ApplicationRecord
  rolify

  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members

  validates :name, presence: true

  scope :asc, -> { order(name: :asc) }
end
