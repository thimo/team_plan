class YearGroup < ApplicationRecord
  belongs_to :season
  has_many :teams
end
