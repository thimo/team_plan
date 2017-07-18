class SoccerField < ApplicationRecord
  has_many :training_schedules

  scope :asc, -> { order(:name) }
  scope :training, -> { where(training: true) }
end
