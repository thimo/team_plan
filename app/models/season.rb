class Season < ApplicationRecord
  has_many :age_groups, dependent: :destroy

  validates_presence_of :name

  scope :asc, -> { order(name: :asc) }
  scope :desc, -> { order(name: :desc) }
  scope :active, -> { where(active: true) }
end
