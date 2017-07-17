class SoccerField < ApplicationRecord
  has_many :soccer_field_parts, dependent: :destroy

  scope :asc, -> { order(:name) }
end
