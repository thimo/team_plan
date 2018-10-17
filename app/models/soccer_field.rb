# frozen_string_literal: true

class SoccerField < ApplicationRecord
  multi_tenant :tenant
  has_many :training_schedules
  has_paper_trail

  scope :asc, -> { order(:name) }
  scope :training, -> { where(training: true) }
end
