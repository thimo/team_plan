class SoccerField < ApplicationRecord
  has_many :training_schedules
  has_paper_trail

  scope :asc, -> { order(:name) }
  scope :training, -> { where(training: true) }
end
