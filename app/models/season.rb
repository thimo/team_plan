class Season < ApplicationRecord
  has_many :year_groups

  validates_presence_of :name
end
