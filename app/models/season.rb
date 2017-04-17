class Season < ApplicationRecord
  include Statussable

  has_many :age_groups, dependent: :destroy

  validates_presence_of :name, :status

  scope :asc, -> { order(name: :asc) }
  scope :desc, -> { order(name: :desc) }

end
