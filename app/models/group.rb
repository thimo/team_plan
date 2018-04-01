class Group < ApplicationRecord
  rolify

  has_many :users

  scope :asc, -> { order(name: :asc) }
end
