class YearGroup < ApplicationRecord
  belongs_to :season
  has_many :teams

  validates_presence_of :name, :season
end
