class YearGroup < ApplicationRecord
  belongs_to :season
  has_many :teams, dependent: :destroy

  validates_presence_of :name, :season

  scope :asc, -> {order(year_of_birth_to: :asc)}
end
