class Training < ApplicationRecord
  include Activatable

  belongs_to :training_schedule

  validates_presence_of :started_at, :ended_at, :training_schedule_id

  scope :not_modified, -> { where(user_modified: false) }
  scope :from_now,     -> { where('started_at > ?', DateTime.now) }
  scope :this_week,    -> (date) { where('started_at > ?', date.beginning_of_week).where('started_at < ?', date.end_of_week) }
end
