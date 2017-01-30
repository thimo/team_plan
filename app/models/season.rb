class Season < ApplicationRecord
  has_many :year_groups, dependent: :destroy

  validates_presence_of :name

  scope :asc, -> { order(name: :asc) }
  scope :desc, -> { order(name: :desc) }
end
