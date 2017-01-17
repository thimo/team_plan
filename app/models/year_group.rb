class YearGroup < ApplicationRecord
  belongs_to :season
  has_many :teams, dependent: :destroy

  validates_presence_of :name, :season
end
